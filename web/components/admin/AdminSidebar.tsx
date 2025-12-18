'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAuth } from '@/context/AuthContext';
import { useLanguage } from '@/context/LanguageContext';
import { LayoutDashboard, Calendar, MessageSquare, Users, BarChart3, FileText, Briefcase, LogOut, Bell, Globe, Settings, Clock } from 'lucide-react';
import { t } from '@/lib/translations';

export default function AdminSidebar() {
  const pathname = usePathname();
  const { signOut } = useAuth();
  const { language, setLanguage } = useLanguage();

  const menuItems = [
    {
      title: t('admin.dashboard', language),
      href: '/admin',
      icon: LayoutDashboard,
    },
    {
      title: t('admin.consultations', language),
      href: '/admin/consultations',
      icon: Briefcase,
    },
    {
      title: t('admin.bookings', language),
      href: '/admin/bookings',
      icon: Calendar,
    },
    {
      title: language === 'ar' ? 'التقويم والمواعيد' : language === 'fr' ? 'Calendrier' : 'Calendar',
      href: '/admin/calendar',
      icon: Clock,
    },
    {
      title: t('admin.messages', language),
      href: '/admin/contacts',
      icon: MessageSquare,
    },
    {
      title: t('admin.users', language),
      href: '/admin/users',
      icon: Users,
    },
    {
      title: t('notifications.title', language),
      href: '/admin/send-notification',
      icon: Bell,
    },
    {
      title: t('admin.documents', language),
      href: '/admin/documents',
      icon: FileText,
    },
    {
      title: t('admin.analytics', language),
      href: '/admin/analytics',
      icon: BarChart3,
    },
    {
      title: t('profile.settings', language),
      href: '/admin/settings',
      icon: Settings,
    },
  ];

  const handleLogout = async () => {
    try {
      await signOut();
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  const toggleLanguage = () => {
    const newLang = language === 'fr' ? 'ar' : language === 'ar' ? 'en' : 'fr';
    setLanguage(newLang);
  };

  const getLanguageLabel = () => {
    switch (language) {
      case 'fr':
        return 'FR';
      case 'ar':
        return 'عربي';
      case 'en':
        return 'EN';
      default:
        return 'FR';
    }
  };

  return (
    <aside className="w-64 bg-[#001F3F] text-white min-h-screen flex flex-col">
      {/* Logo */}
      <div className="p-6 border-b border-white/10">
        <Link href="/admin" className="flex items-center gap-2">
          <div className="w-8 h-8 bg-[#D4AF37] rounded-lg flex items-center justify-center font-bold text-[#001F3F]">
            S
          </div>
          <div>
            <h1 className="text-lg font-bold">Sygma Admin</h1>
            <p className="text-xs text-blue-200">Management Portal</p>
          </div>
        </Link>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4">
        <ul className="space-y-2">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href || (item.href !== '/admin' && pathname.startsWith(item.href));

            return (
              <li key={item.href}>
                <Link
                  href={item.href}
                  className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${
                    isActive
                      ? 'bg-[#D4AF37] text-[#001F3F] font-semibold'
                      : 'text-blue-100 hover:bg-white/10'
                  }`}
                >
                  <Icon className="h-5 w-5" />
                  <span>{item.title}</span>
                </Link>
              </li>
            );
          })}
        </ul>
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-white/10 space-y-2">
        {/* Language Toggle */}
        <button
          onClick={toggleLanguage}
          className="flex items-center gap-3 px-4 py-3 rounded-lg text-blue-100 hover:bg-white/10 transition-colors w-full"
          title={t('profile.language', language)}
        >
          <Globe className="h-5 w-5" />
          <span className="font-semibold">{getLanguageLabel()}</span>
        </button>

        {/* Logout */}
        <button
          onClick={handleLogout}
          className="flex items-center gap-3 px-4 py-3 rounded-lg text-blue-100 hover:bg-white/10 transition-colors w-full"
        >
          <LogOut className="h-5 w-5" />
          <span>{t('auth.logout', language)}</span>
        </button>
      </div>
    </aside>
  );
}
