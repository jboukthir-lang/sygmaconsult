import Stripe from 'stripe';

if (!process.env.STRIPE_SECRET_KEY) {
  throw new Error('STRIPE_SECRET_KEY is not defined in environment variables');
}

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2024-11-20.acacia',
  typescript: true,
});

export const CURRENCY = 'eur';

// Helper function to format amount for Stripe (convert EUR to cents)
export function formatAmountForStripe(amount: number, currency: string = CURRENCY): number {
  return Math.round(amount * 100);
}

// Helper function to format amount for display (convert cents to EUR)
export function formatAmountFromStripe(amount: number, currency: string = CURRENCY): number {
  return amount / 100;
}
