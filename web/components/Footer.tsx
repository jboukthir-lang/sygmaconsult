'use client';

import Link from 'next/link';
import { Facebook, Linkedin, Twitter, Mail, Phone, MapPin } from 'lucide-react';
import { useLanguage } from '@/context/LanguageContext';

export default function Footer() {
    const { t } = useLanguage();

    return (
        <footer className="bg-[#001F3F] text-white pt-16 pb-8">
            <div className="container mx-auto px-4 md:px-6">
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12 mb-12">

                    {/* Brand Column */}
                    <div className="space-y-4">
                        <Link className="flex items-center gap-2 font-serif text-2xl font-bold text-white" href="/">
                            SYGMA<span className="text-[#D4AF37]">CONSULT</span>
                        </Link>
                        <p className="text-gray-300 text-sm leading-relaxed">
                            {t.footer.desc}
                        </p>
                        <div className="flex gap-4">
                            <Link href="#" className="text-gray-400 hover:text-[#D4AF37] transition-colors"><Linkedin className="h-5 w-5" /></Link>
                            <Link href="#" className="text-gray-400 hover:text-[#D4AF37] transition-colors"><Twitter className="h-5 w-5" /></Link>
                            <Link href="#" className="text-gray-400 hover:text-[#D4AF37] transition-colors"><Facebook className="h-5 w-5" /></Link>
                        </div>
                    </div>

                    {/* Quick Links */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-bold text-[#D4AF37]">{t.footer.quick_links}</h3>
                        <ul className="space-y-2 text-sm text-gray-300">
                            <li><Link href="/about" className="hover:text-white transition-colors">{t.nav.about}</Link></li>
                            <li><Link href="/services" className="hover:text-white transition-colors">{t.nav.services}</Link></li>
                            <li><Link href="/insights" className="hover:text-white transition-colors">{t.nav.insights}</Link></li>
                            <li><Link href="/careers" className="hover:text-white transition-colors">{t.footer.careers}</Link></li>
                            <li><Link href="/privacy" className="hover:text-white transition-colors">{t.footer.privacy}</Link></li>
                        </ul>
                    </div>

                    {/* Services */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-bold text-[#D4AF37]">{t.footer.expertise}</h3>
                        <ul className="space-y-2 text-sm text-gray-300">
                            <li><Link href="/services/strategic" className="hover:text-white transition-colors">{t.services.items.strategic.title}</Link></li>
                            <li><Link href="/services/financial-legal" className="hover:text-white transition-colors">{t.services.items.financial.title}</Link></li>
                            <li><Link href="/services/visa" className="hover:text-white transition-colors">{t.services.items.visa.title}</Link></li>
                            <li><Link href="/services/corporate" className="hover:text-white transition-colors">{t.services.items.corporate.title}</Link></li>
                            <li><Link href="/services/real-estate" className="hover:text-white transition-colors">{t.services.items.realestate.title}</Link></li>
                        </ul>
                    </div>

                    {/* Contact */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-bold text-[#D4AF37]">{t.footer.contact}</h3>
                        <ul className="space-y-4 text-sm text-gray-300">
                            <li className="flex items-start gap-3">
                                <MapPin className="h-5 w-5 text-[#D4AF37] shrink-0" />
                                <span>
                                    <strong>{t.footer.address_paris}:</strong> 123 Avenue des Champs-Élysées, 75008 Paris<br />
                                    <strong>{t.footer.address_tunis}:</strong> Les Berges du Lac II, 1053 Tunis
                                </span>
                            </li>
                            <li className="flex items-center gap-3">
                                <Phone className="h-5 w-5 text-[#D4AF37] shrink-0" />
                                <span>+33 7 52 03 47 86</span>
                            </li>
                            <li className="flex items-center gap-3">
                                <Mail className="h-5 w-5 text-[#D4AF37] shrink-0" />
                                <span>contact@sygma-consult.com</span>
                            </li>
                        </ul>
                    </div>
                </div>

                <div className="border-t border-gray-800 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
                    <p className="text-xs text-gray-500">
                        © {new Date().getFullYear()} Sygma Consult. {t.footer.rights}
                    </p>
                    <div className="flex gap-6 text-xs text-gray-500">
                        <Link href="/terms" className="hover:text-white">{t.footer.terms}</Link>
                        <Link href="/legal" className="hover:text-white">{t.footer.legal}</Link>
                    </div>
                </div>
            </div>
        </footer>
    );
}
