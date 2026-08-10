import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

const openAIApiKey = defineSecret("OPENAI_API_KEY");

interface ChatMessage {
  role: "user" | "assistant";
  text: string;
}

interface ChatWithAIRequest {
  history: ChatMessage[];
  message: string;
}

const SYSTEM_PROMPT = `You are a supportive, empathetic assistant inside a student mental health app called Solace. You provide general emotional support, active listening, and light coping strategies (breathing exercises, grounding techniques, journaling prompts). You are NOT a licensed therapist and must never diagnose, prescribe, or claim to replace professional care. If a student expresses thoughts of self-harm, suicide, or being in immediate danger, gently but clearly encourage them to contact emergency services or the 988 Suicide & Crisis Lifeline (call or text 988), and to reach out to a campus counselor. Keep responses concise, warm, and non-clinical.`;

/**
 * Proxies chat messages to OpenAI so the API key never has to live on-device.
 * Client contract: SolaceCore's `AIChatServicing` calls this with the prior
 * conversation history plus the newest user message, and expects
 * `{ reply: string }` back.
 */
export const chatWithAI = onCall<ChatWithAIRequest>(
  { secrets: [openAIApiKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be signed in to use the support chat.");
    }

    const { history, message } = request.data;
    if (typeof message !== "string" || message.trim().length === 0) {
      throw new HttpsError("invalid-argument", "message must be a non-empty string.");
    }

    const messages = [
      { role: "system" as const, content: SYSTEM_PROMPT },
      ...(Array.isArray(history) ? history : []).map((entry) => ({
        role: entry.role === "assistant" ? ("assistant" as const) : ("user" as const),
        content: entry.text,
      })),
      { role: "user" as const, content: message },
    ];

    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${openAIApiKey.value()}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages,
        max_tokens: 400,
        temperature: 0.7,
      }),
    });

    if (!response.ok) {
      if (response.status === 429) {
        throw new HttpsError(
          "resource-exhausted",
          "The assistant is receiving too many requests. Please try again shortly."
        );
      }
      throw new HttpsError("unavailable", "The assistant is temporarily unavailable.");
    }

    const data = (await response.json()) as {
      choices?: { message?: { content?: string } }[];
    };
    const reply = data.choices?.[0]?.message?.content?.trim();
    if (!reply) {
      throw new HttpsError("internal", "The assistant returned an empty response.");
    }

    return { reply };
  }
);
