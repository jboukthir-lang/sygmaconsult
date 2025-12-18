'use client';

import Image from 'next/image';
import Link from 'next/link';
import { ArrowRight } from 'lucide-react';
import { useLanguage } from '@/context/LanguageContext';
import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';

export default function Hero() {
    const { t } = useLanguage();
    const [heroImageUrl, setHeroImageUrl] = useState<string>('/hero.svg');

    const fetchHeroImage = async () => {
        try {
            const { data } = await supabase
                .from('hero_images')
                .select('image_url')
                .eq('is_active', true)
                .single();

            if (data && data.image_url) {
                setHeroImageUrl(data.image_url);
            }
        } catch {
            console.log('Using default hero image');
        }
    };

    useEffect(() => {
        fetchHeroImage();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    return (
        <section className="relative w-full overflow-hidden bg-white">
            <div className="container mx-auto px-4 md:px-6">
                <div className="grid gap-6 lg:grid-cols-2 lg:gap-12 xl:grid-cols-2 items-center min-h-[calc(100vh-80px)] py-12 lg:py-0">

                    {/* Content Column */}
                    <div className="flex flex-col justify-center space-y-8 order-2 lg:order-1">
                        <div className="space-y-4">
                            <div className="inline-block rounded-full bg-[#F8F9FA] px-3 py-1 text-sm font-semibold text-[#D4AF37] border border-[#D4AF37]/20">
                                {t.hero.badge}
                            </div>
                            <h1 className="text-4xl font-bold tracking-tighter sm:text-5xl xl:text-6xl/none text-[#001F3F] font-serif">
                                {t.hero.title_start} <span className="text-[#D4AF37]">{t.hero.paris}</span> & <span className="text-[#D4AF37]">{t.hero.tunis}</span>
                            </h1>
                            <p className="max-w-[600px] text-[#4A4A4A] md:text-xl leading-relaxed">
                                {t.hero.subtitle}
                            </p>
                        </div>
                        <div className="flex flex-col gap-4 min-[400px]:flex-row">
                            <Link
                                className="inline-flex h-12 items-center justify-center rounded-lg bg-[#D4AF37] px-8 text-sm font-medium text-white shadow transition-all hover:bg-[#C5A028] hover:shadow-lg focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-[#D4AF37]"
                                href="/book"
                            >
                                {t.hero.cta_book}
                                <ArrowRight className="ml-2 h-4 w-4" />
                            </Link>
                            <Link
                                className="inline-flex h-12 items-center justify-center rounded-lg border border-[#001F3F] bg-transparent px-8 text-sm font-medium text-[#001F3F] shadow-sm transition-colors hover:bg-[#F8F9FA] focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-[#001F3F]"
                                href="/services"
                            >
                                {t.hero.cta_services}
                            </Link>
                        </div>
                    </div>

                    {/* Image Column */}
                    <div className="order-1 lg:order-2 relative h-[300px] lg:h-full min-h-[400px] w-full lg:min-h-[600px] rounded-2xl overflow-hidden shadow-2xl">
                        <div className="absolute inset-0 bg-[#001F3F]/10 z-10"></div> {/* Overlay */}
                        <Image
                            src={heroImageUrl}
                            alt="Sygma Consult Corporate Meeting"
                            fill
                            className="object-cover transition-transform duration-700 hover:scale-105"
                            priority
                        />
                    </div>

                </div>
            </div>
        </section>
    );
}
