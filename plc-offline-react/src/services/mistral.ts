import axios from 'axios';

const MISTRAL_API_KEY = 'IOxxOSCGW86qkK8VbaeKefRkpNkd0cOg';
const MISTRAL_API_URL = 'https://api.mistral.ai/v1/chat/completions';

export interface MistralMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface MistralResponse {
  id: string;
  object: string;
  created: number;
  model: string;
  choices: Array<{
    index: number;
    message: MistralMessage;
    finish_reason: string;
  }>;
  usage: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
}

export const mistralClient = {
  async generateLadder(description: string): Promise<string> {
    const messages: MistralMessage[] = [
      {
        role: 'system',
        content: `You are a PLC programming expert. Generate ladder logic programs based on user descriptions. 
        Output ONLY the ladder logic in JSON format with this structure:
        {
          "rungs": [
            {
              "id": 1,
              "elements": [
                {"type": "contact_no", "address": "I0.0", "label": "Start"},
                {"type": "coil", "address": "Q0.0", "label": "Motor"}
              ]
            }
          ]
        }
        Element types: contact_no, contact_nc, coil, timer_on, timer_off, counter_up, counter_down`
      },
      {
        role: 'user',
        content: description
      }
    ];

    try {
      const response = await axios.post<MistralResponse>(
        MISTRAL_API_URL,
        {
          model: 'mistral-large-latest',
          messages,
          temperature: 0.3,
          max_tokens: 2000
        },
        {
          headers: {
            'Authorization': `Bearer ${MISTRAL_API_KEY}`,
            'Content-Type': 'application/json'
          }
        }
      );

      const content = response.data.choices[0].message.content;
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      return jsonMatch ? jsonMatch[0] : content;
    } catch (error) {
      console.error('Mistral API error:', error);
      throw new Error('Failed to generate ladder program');
    }
  },

  async explainProgram(program: string): Promise<string> {
    const messages: MistralMessage[] = [
      {
        role: 'system',
        content: 'You are a PLC programming expert. Explain ladder logic programs clearly and concisely.'
      },
      {
        role: 'user',
        content: `Explain this ladder logic program:\n\n${program}`
      }
    ];

    try {
      const response = await axios.post<MistralResponse>(
        MISTRAL_API_URL,
        {
          model: 'mistral-large-latest',
          messages,
          temperature: 0.5,
          max_tokens: 1500
        },
        {
          headers: {
            'Authorization': `Bearer ${MISTRAL_API_KEY}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return response.data.choices[0].message.content;
    } catch (error) {
      console.error('Mistral API error:', error);
      throw new Error('Failed to explain program');
    }
  },

  async debugProgram(program: string, issue: string): Promise<string> {
    const messages: MistralMessage[] = [
      {
        role: 'system',
        content: 'You are a PLC debugging expert. Identify issues in ladder logic programs and suggest fixes.'
      },
      {
        role: 'user',
        content: `Debug this ladder logic program.\n\nProgram:\n${program}\n\nIssue: ${issue || 'General debugging needed'}`
      }
    ];

    try {
      const response = await axios.post<MistralResponse>(
        MISTRAL_API_URL,
        {
          model: 'mistral-large-latest',
          messages,
          temperature: 0.4,
          max_tokens: 2000
        },
        {
          headers: {
            'Authorization': `Bearer ${MISTRAL_API_KEY}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return response.data.choices[0].message.content;
    } catch (error) {
      console.error('Mistral API error:', error);
      throw new Error('Failed to debug program');
    }
  }
};
