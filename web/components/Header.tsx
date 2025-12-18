'use client';

import Link from 'next/link';
import { Menu, Phone, LogIn, LogOut, User } from 'lucide-react';
import { useLanguage } from '@/context/LanguageContext';
import { useAuth } from '@/context/AuthContext';
import NotificationBell from './NotificationBell';
export default function Header() {
    const { t, language, setLanguage } = useLanguage();
    const { user, signOut } = useAuth();

    const handleSignOut = async () => {
        try {
            await signOut();
        } catch (error) {
            console.error('Sign out error:', error);
        }
    };

    return (
        <header className="sticky top-0 z-50 w-full border-b border-gray-100 bg-white/95 backdrop-blur supports-[backdrop-filter]:bg-white/60">
            <div className="container mx-auto px-4 md:px-6">
                <div className="flex h-20 items-center justify-between">
                    <Link className="flex items-center gap-2 font-serif text-2xl font-bold text-[#001F3F]" href="/">
                        SYGMA<span className="text-[#D4AF37]">CONSULT</span>
                    </Link>

                    <nav className="hidden md:flex gap-8 text-sm font-medium text-[#4A4A4A]">
                        <Link className="hover:text-[#001F3F] transition-colors" href="/">{t.nav.home}</Link>
                        <Link className="hover:text-[#001F3F] transition-colors" href="/services">{t.nav.services}</Link>
                        <Link className="hover:text-[#001F3F] transition-colors" href="/about">{t.nav.about}</Link>
                        <Link className="hover:text-[#001F3F] transition-colors" href="/insights">{t.nav.insights}</Link>
                        <Link className="hover:text-[#001F3F] transition-colors" href="/contact">{t.nav.contact}</Link>
                    </nav>

                    <div className="flex items-center gap-4">
                        <Link
                            className="hidden md:inline-flex items-center justify-center rounded-lg border border-[#001F3F] bg-transparent px-6 py-2 text-sm font-medium text-[#001F3F] shadow-sm transition-colors hover:bg-[#F8F9FA] focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-[#001F3F]"
                            href="/contact"
                        >
                            <Phone className="mr-2 h-4 w-4" />
                            {t.nav.contact}
                        </Link>

                        {/* Language Switcher */}
                        <div className="hidden md:flex items-center gap-2 text-sm font-medium text-[#001F3F] border-r border-gray-200 pr-4 mr-2">
                            <button onClick={() => setLanguage('en')} className={`${language === 'en' ? 'text-[#D4AF37] font-bold' : 'hover:text-[#D4AF37]'} transition-colors`}>EN</button>
                            <span className="text-gray-300">|</span>
                            <button onClick={() => setLanguage('fr')} className={`${language === 'fr' ? 'text-[#D4AF37] font-bold' : 'hover:text-[#D4AF37] opacity-60'} transition-colors`}>FR</button>
                            <span className="text-gray-300">|</span>
                            <button onClick={() => setLanguage('ar')} className={`${language === 'ar' ? 'text-[#D4AF37] font-bold' : 'hover:text-[#D4AF37] opacity-60'} transition-colors`}>AR</button>
                        </div>

                        {/* Auth Button */}
                        {user ? (
                            <div className="hidden md:flex items-center gap-3">
                                <NotificationBell />
                                <Link
                                    href="/profile"
                                    className="flex items-center gap-2 px-3 py-2 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
                                >
                                    {user.photoURL ? (
                                        <img src={user.photoURL} alt="Profile" className="h-8 w-8 rounded-full" />
                                    ) : (
                                        <User className="h-4 w-4 text-[#001F3F]" />
                                    )}
                                    <span className="text-sm font-medium text-[#001F3F] max-w-[100px] truncate">
                                        {user.displayName || user.email}
                                    </span>
                                </Link>
                                <button
                                    onClick={handleSignOut}
                                    className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-[#001F3F] hover:text-[#D4AF37] transition-colors"
                                >
                                    <LogOut className="h-4 w-4" />
                                    Sign Out
                                </button>
                            </div>
                        ) : (
                            <Link
                                href="/login"
                                className="hidden md:inline-flex items-center gap-2 px-4 py-2 rounded-lg border border-[#001F3F] text-sm font-medium text-[#001F3F] hover:bg-[#F8F9FA] transition-colors"
                            >
                                <LogIn className="h-4 w-4" />
                                Sign In
                            </Link>
                        )}

                        <Link
                            className="inline-flex items-center justify-center rounded-lg bg-[#D4AF37] px-6 py-2 text-sm font-medium text-white shadow transition-colors hover:bg-[#C5A028] focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-[#D4AF37]"
                            href="/book"
                        >
                            {t.nav.book}
                        </Link>
                        <button className="md:hidden">
                            <Menu className="h-6 w-6 text-[#001F3F]" />
                        </button>
                    </div>
                </div>
            </div>
        </header>
    );
}
