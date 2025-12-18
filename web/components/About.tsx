'use client';

import Link from 'next/link';
import { CheckCircle2 } from 'lucide-react';
import { useLanguage } from '@/context/LanguageContext';

export default function About() {
    const { t } = useLanguage();

    return (
        <section className="py-20 bg-white" id="about">
            <div className="container mx-auto px-4 md:px-6">
                <div className="grid gap-12 lg:grid-cols-2 items-center">
                    <div className="space-y-6">
                        <h2 className="text-3xl font-bold tracking-tighter sm:text-4xl md:text-5xl text-[#001F3F] font-serif">
                            {t.about.title_start} <span className="text-[#D4AF37]">{t.about.europe}</span> & <span className="text-[#D4AF37]">{t.about.africa}</span>
                        </h2>
                        <p className="text-lg text-[#4A4A4A] leading-relaxed">
                            {t.about.description}
                        </p>
                        <ul className="space-y-4">
                            {t.about.points.map((item, i) => (
                                <li key={i} className="flex items-center gap-3">
                                    <CheckCircle2 className="h-5 w-5 text-[#D4AF37]" />
                                    <span className="text-[#001F3F] font-medium">{item}</span>
                                </li>
                            ))}
                        </ul>
                        <div className="pt-4">
                            <Link
                                href="/about"
                                className="inline-flex h-12 items-center justify-center rounded-lg border border-[#001F3F] bg-transparent px-8 text-sm font-medium text-[#001F3F] shadow-sm transition-colors hover:bg-[#001F3F] hover:text-white focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-[#001F3F]"
                            >
                                {t.about.cta_more}
                            </Link>
                        </div>
                    </div>
                    <div className="relative h-[400px] lg:h-[500px] rounded-2xl overflow-hidden bg-[#F8F9FA] border border-gray-100 shadow-xl p-8 flex items-center justify-center">
                        {/* Placeholder for map or office image */}
                        <div className="text-center space-y-4">
                            <div className="text-6xl font-serif text-[#001F3F]/20 font-bold">{t.about.paris}</div>
                            <div className="w-px h-20 bg-[#D4AF37] mx-auto"></div>
                            <div className="text-6xl font-serif text-[#001F3F]/20 font-bold">{t.about.tunis}</div>
                            <p className="text-sm text-[#4A4A4A] mt-4 max-w-xs mx-auto">
                                {t.about.map_caption}
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    );
}
