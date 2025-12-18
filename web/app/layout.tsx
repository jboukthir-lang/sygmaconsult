import type { Metadata } from "next";
import { Alexandria, Montserrat } from "next/font/google";
import "./globals.css";

const alexandria = Alexandria({
  variable: "--font-alexandria",
  subsets: ["arabic", "latin"],
  display: "swap",
});

const montserrat = Montserrat({
  variable: "--font-montserrat",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "Sygma Consult | Digital Transformation & Strategy",
  description: "Your trusted partner in Paris and Tunis for digital transformation, legal consulting, and strategic growth.",
  icons: {
    icon: [
      { url: '/favicon.svg', type: 'image/svg+xml' },
      { url: '/icon.svg', type: 'image/svg+xml', sizes: '32x32' },
    ],
    apple: '/icon.svg',
  },
  openGraph: {
    title: "Sygma Consult | Digital Transformation & Strategy",
    description: "Your trusted partner in Paris and Tunis for digital transformation, legal consulting, and strategic growth.",
    images: ['/logo.svg'],
    type: 'website',
    locale: 'fr_FR',
    alternateLocale: ['ar_TN', 'en_US'],
  },
};

import Footer from "@/components/Footer";
import ChatBot from "@/components/ChatBot";

import { LanguageProvider } from "@/context/LanguageContext";
import { AuthProvider } from "@/context/AuthContext";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${alexandria.variable} ${montserrat.variable} antialiased font-sans flex flex-col min-h-screen`}
      >
        <AuthProvider>
          <LanguageProvider>
            {children}
            <Footer />
            <ChatBot />
          </LanguageProvider>
        </AuthProvider>
      </body>
    </html>
  );
}
