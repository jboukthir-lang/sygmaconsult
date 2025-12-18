'use client';

import Header from "@/components/Header";
import Link from "next/link";
import { useLanguage } from "@/context/LanguageContext";

export default function InsightsPage() {
    const { t, language } = useLanguage();

    const getArticleColor = (index: number) => {
        const colors = [
            "bg-blue-100 text-blue-800",
            "bg-green-100 text-green-800",
            "bg-purple-100 text-purple-800"
        ];
        return colors[index % colors.length];
    };

    return (
        <main className="min-h-screen bg-[#F8F9FA]">
            <Header />

            <div className="bg-[#001F3F] text-white py-20 text-center">
                <h1 className="text-4xl font-serif font-bold">{t.insights.title}</h1>
                <p className="text-blue-200 mt-4">
                    {t.insights.subtitle}
                </p>
            </div>

            <div className="container mx-auto px-4 py-16">
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                    {t.insights.articles.map((article, i) => (
                        <div key={i} className="bg-white rounded-2xl overflow-hidden shadow-sm hover:shadow-lg transition-shadow border border-gray-100 group">
                            <div className="h-48 bg-gray-200 w-full relative">
                                {/* Placeholder for blog image */}
                                <div className="absolute inset-0 flex items-center justify-center text-gray-400 font-serif text-4xl opacity-20 bg-[#001F3F]">
                                    SYGMA
                                </div>
                            </div>
                            <div className="p-6">
                                <div className="flex justify-between items-center mb-4">
                                    <span className={`px-3 py-1 text-xs font-bold rounded-full ${getArticleColor(i)}`}>
                                        {article.category}
                                    </span>
                                    <span className="text-sm text-gray-400">{article.date}</span>
                                </div>
                                <h3 className="text-xl font-bold text-[#001F3F] mb-2 group-hover:text-[#D4AF37] transition-colors">
                                    {article.title}
                                </h3>
                                <p className="text-gray-600 text-sm mb-4">
                                    {article.summary}
                                </p>
                                <Link href="#" className="text-[#001F3F] font-bold text-sm hover:underline">
                                    {t.insights.read_more} {language === 'ar' ? '←' : '→'}
                                </Link>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </main>
    );
}
