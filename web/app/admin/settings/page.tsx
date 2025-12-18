'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import { useLanguage } from '@/context/LanguageContext';
import { t } from '@/lib/translations';
import { Settings, Upload, Save, Image as ImageIcon, Globe, Mail, Phone, MapPin, Facebook, Twitter, Instagram, Linkedin, Youtube } from 'lucide-react';
import Image from 'next/image';

interface SiteSetting {
  id: string;
  key: string;
  value_text: string | null;
  value_json: any;
  description: string | null;
}

export default function AdminSettingsPage() {
  const { language } = useLanguage();
  const [settings, setSettings] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [uploadingLogo, setUploadingLogo] = useState(false);
  const [uploadingFavicon, setUploadingFavicon] = useState(false);
  const [uploadingHero, setUploadingHero] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  useEffect(() => {
    fetchSettings();
  }, []);

  async function fetchSettings() {
    try {
      const { data, error } = await supabase
        .from('site_settings')
        .select('*');

      if (error) throw error;

      const settingsMap: Record<string, string> = {};
      data?.forEach((setting: SiteSetting) => {
        settingsMap[setting.key] = setting.value_text || '';
      });

      setSettings(settingsMap);
    } catch (error) {
      console.error('Error fetching settings:', error);
      showMessage('error', 'Erreur lors du chargement des paramètres');
    } finally {
      setLoading(false);
    }
  }

  async function handleSaveSettings(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);

    try {
      // Update each setting
      const updates = Object.entries(settings).map(([key, value]) =>
        supabase
          .from('site_settings')
          .upsert({ key, value_text: value, updated_at: new Date().toISOString() })
      );

      await Promise.all(updates);
      showMessage('success', 'Paramètres enregistrés avec succès!');
    } catch (error) {
      console.error('Error saving settings:', error);
      showMessage('error', 'Erreur lors de l\'enregistrement');
    } finally {
      setSaving(false);
    }
  }

  async function handleFileUpload(file: File, settingKey: string, setUploading: (val: boolean) => void) {
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith('image/')) {
      showMessage('error', 'Veuillez sélectionner une image valide');
      return;
    }

    // Validate file size (max 2MB)
    if (file.size > 2 * 1024 * 1024) {
      showMessage('error', 'L\'image ne doit pas dépasser 2MB');
      return;
    }

    setUploading(true);

    try {
      const fileExt = file.name.split('.').pop();
      const fileName = `${settingKey}-${Date.now()}.${fileExt}`;
      const filePath = `settings/${fileName}`;

      // Upload to Supabase Storage
      const { error: uploadError, data } = await supabase.storage
        .from('public')
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: true,
        });

      if (uploadError) throw uploadError;

      // Get public URL
      const { data: { publicUrl } } = supabase.storage
        .from('public')
        .getPublicUrl(filePath);

      // Update settings
      setSettings(prev => ({ ...prev, [settingKey]: publicUrl }));

      // Save to database
      await supabase
        .from('site_settings')
        .upsert({
          key: settingKey,
          value_text: publicUrl,
          updated_at: new Date().toISOString(),
        });

      showMessage('success', 'Image téléchargée avec succès!');
    } catch (error: any) {
      console.error('Error uploading file:', error);
      showMessage('error', error.message || 'Erreur lors du téléchargement');
    } finally {
      setUploading(false);
    }
  }

  function showMessage(type: 'success' | 'error', text: string) {
    setMessage({ type, text });
    setTimeout(() => setMessage(null), 5000);
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-[#001F3F] border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600">Chargement des paramètres...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-[#001F3F]">
            <Settings className="inline-block h-8 w-8 mr-2" />
            Paramètres du site
          </h1>
          <p className="text-gray-600 mt-1">
            Gérer les paramètres généraux et les images du site
          </p>
        </div>
      </div>

      {/* Success/Error Message */}
      {message && (
        <div
          className={`p-4 rounded-lg border ${
            message.type === 'success'
              ? 'bg-green-50 border-green-200 text-green-800'
              : 'bg-red-50 border-red-200 text-red-800'
          }`}
        >
          {message.text}
        </div>
      )}

      <form onSubmit={handleSaveSettings} className="space-y-6">
        {/* Images Section */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-xl font-bold text-[#001F3F] mb-6 flex items-center gap-2">
            <ImageIcon className="h-6 w-6" />
            Images et Logo
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {/* Logo Upload */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Logo du site
              </label>
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-[#001F3F] transition-colors">
                {settings.logo_url ? (
                  <div className="mb-4">
                    <Image
                      src={settings.logo_url}
                      alt="Logo"
                      width={200}
                      height={80}
                      className="mx-auto object-contain"
                    />
                  </div>
                ) : (
                  <ImageIcon className="h-12 w-12 text-gray-400 mx-auto mb-2" />
                )}
                <label className="cursor-pointer">
                  <span className="inline-flex items-center gap-2 px-4 py-2 bg-[#001F3F] text-white rounded-lg hover:bg-[#003366] transition-colors">
                    {uploadingLogo ? (
                      <>
                        <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                        Téléchargement...
                      </>
                    ) : (
                      <>
                        <Upload className="h-4 w-4" />
                        Télécharger le logo
                      </>
                    )}
                  </span>
                  <input
                    type="file"
                    accept="image/*"
                    className="hidden"
                    onChange={(e) => {
                      const file = e.target.files?.[0];
                      if (file) handleFileUpload(file, 'logo_url', setUploadingLogo);
                    }}
                    disabled={uploadingLogo}
                  />
                </label>
                <p className="text-xs text-gray-500 mt-2">
                  PNG, JPG, SVG (max 2MB)
                </p>
              </div>
            </div>

            {/* Favicon Upload */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Favicon
              </label>
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-[#001F3F] transition-colors">
                {settings.favicon_url ? (
                  <div className="mb-4">
                    <Image
                      src={settings.favicon_url}
                      alt="Favicon"
                      width={64}
                      height={64}
                      className="mx-auto"
                    />
                  </div>
                ) : (
                  <ImageIcon className="h-12 w-12 text-gray-400 mx-auto mb-2" />
                )}
                <label className="cursor-pointer">
                  <span className="inline-flex items-center gap-2 px-4 py-2 bg-[#001F3F] text-white rounded-lg hover:bg-[#003366] transition-colors">
                    {uploadingFavicon ? (
                      <>
                        <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                        Téléchargement...
                      </>
                    ) : (
                      <>
                        <Upload className="h-4 w-4" />
                        Télécharger le favicon
                      </>
                    )}
                  </span>
                  <input
                    type="file"
                    accept="image/*"
                    className="hidden"
                    onChange={(e) => {
                      const file = e.target.files?.[0];
                      if (file) handleFileUpload(file, 'favicon_url', setUploadingFavicon);
                    }}
                    disabled={uploadingFavicon}
                  />
                </label>
                <p className="text-xs text-gray-500 mt-2">
                  ICO, PNG (32x32 ou 64x64)
                </p>
              </div>
            </div>

            {/* Hero Image Upload */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Image d'accueil (Hero)
              </label>
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-[#001F3F] transition-colors">
                {settings.hero_image_url ? (
                  <div className="mb-4">
                    <Image
                      src={settings.hero_image_url}
                      alt="Hero"
                      width={200}
                      height={100}
                      className="mx-auto object-cover rounded"
                    />
                  </div>
                ) : (
                  <ImageIcon className="h-12 w-12 text-gray-400 mx-auto mb-2" />
                )}
                <label className="cursor-pointer">
                  <span className="inline-flex items-center gap-2 px-4 py-2 bg-[#001F3F] text-white rounded-lg hover:bg-[#003366] transition-colors">
                    {uploadingHero ? (
                      <>
                        <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                        Téléchargement...
                      </>
                    ) : (
                      <>
                        <Upload className="h-4 w-4" />
                        Télécharger l'image
                      </>
                    )}
                  </span>
                  <input
                    type="file"
                    accept="image/*"
                    className="hidden"
                    onChange={(e) => {
                      const file = e.target.files?.[0];
                      if (file) handleFileUpload(file, 'hero_image_url', setUploadingHero);
                    }}
                    disabled={uploadingHero}
                  />
                </label>
                <p className="text-xs text-gray-500 mt-2">
                  JPG, PNG (max 2MB)
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Company Info Section */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-xl font-bold text-[#001F3F] mb-6 flex items-center gap-2">
            <Globe className="h-6 w-6" />
            Informations de l'entreprise
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Nom de l'entreprise
              </label>
              <input
                type="text"
                value={settings.company_name || ''}
                onChange={(e) =>
                  setSettings((prev) => ({ ...prev, company_name: e.target.value }))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#001F3F]/20"
                placeholder="Sygma Consult"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center gap-2">
                <Mail className="h-4 w-4" />
                Email administrateur
              </label>
              <input
                type="email"
                value={settings.admin_email || ''}
                onChange={(e) =>
                  setSettings((prev) => ({ ...prev, admin_email: e.target.value }))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#001F3F]/20"
                placeholder="admin@sygmaconsult.com"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center gap-2">
                <Phone className="h-4 w-4" />
                Téléphone
              </label>
              <input
                type="tel"
                value={settings.company_phone || ''}
                onChange={(e) =>
                  setSettings((prev) => ({ ...prev, company_phone: e.target.value }))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#001F3F]/20"
                placeholder="+33 1 23 45 67 89"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center gap-2">
                <MapPin className="h-4 w-4" />
                Adresse
              </label>
              <input
                type="text"
                value={settings.company_address || ''}
                onChange={(e) =>
                  setSettings((prev) => ({ ...prev, company_address: e.target.value }))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#001F3F]/20"
                placeholder="Paris, France"
              />
            </div>
          </div>
        </div>

        {/* Social Media Section */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-xl font-bold text-[#001F3F] mb-6 flex items-center gap-2">
            <Globe className="h-6 w-6" />
            Réseaux sociaux
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center gap-2">
                <Facebook className="h-4 w-4 text-blue-600" />
                Facebook
              </label>
              <input
                type="url"
                value={settings.facebook_url || ''}
                onChange={(e) =>
                  setSettings((prev) => ({ ...prev, facebook_url: e.target.value }))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#001F3F]/20"
                placeholder="https://facebook.com/sygmaconsult"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center gap-2">
                <Twitter className="h-4 w-4 text-blue-400" />
                Twitter / X
              </label>
              <input
                type="url"
                value={settings.twitter_url || ''}
                onChange={(e) =>
                  setSettings((prev) => ({ ...prev, twitter_url: e.target.value }))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#001F3F]/20"
                placeholder="https://twitter.com/sygmaconsult"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center gap-2">
                <Instagram className="h-4 w-4 text-pink-600" />
                Instagram
              </label>
              <input
                type="url"
                value={settings.instagram_url || ''}
                onChange={(e) =>
                  setSettings((prev) => ({ ...prev, instagram_url: e.target.value }))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#001F3F]/20"
                placeholder="https://instagram.com/sygmaconsult"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center gap-2">
                <Linkedin className="h-4 w-4 text-blue-700" />
                LinkedIn
              </label>
              <input
                type="url"
                value={settings.linkedin_url || ''}
                onChange={(e) =>
                  setSettings((prev) => ({ ...prev, linkedin_url: e.target.value }))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#001F3F]/20"
                placeholder="https://linkedin.com/company/sygmaconsult"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center gap-2">
                <Youtube className="h-4 w-4 text-red-600" />
                YouTube
              </label>
              <input
                type="url"
                value={settings.youtube_url || ''}
                onChange={(e) =>
                  setSettings((prev) => ({ ...prev, youtube_url: e.target.value }))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#001F3F]/20"
                placeholder="https://youtube.com/@sygmaconsult"
              />
            </div>
          </div>
        </div>

        {/* About Text - Multi-language */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-xl font-bold text-[#001F3F] mb-6">
            À propos (Texte principal)
          </h2>

          <div className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Français
              </label>
              <textarea
                value={settings.about_text_fr || ''}
                onChange={(e) =>
                  setSettings((prev) => ({ ...prev, about_text_fr: e.target.value }))
                }
                rows={4}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#001F3F]/20"
                placeholder="Texte de présentation en français..."
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                العربية (Arabic)
              </label>
              <textarea
                value={settings.about_text_ar || ''}
                onChange={(e) =>
                  setSettings((prev) => ({ ...prev, about_text_ar: e.target.value }))
                }
                rows={4}
                dir="rtl"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#001F3F]/20"
                placeholder="...نص تعريفي بالعربية"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                English
              </label>
              <textarea
                value={settings.about_text_en || ''}
                onChange={(e) =>
                  setSettings((prev) => ({ ...prev, about_text_en: e.target.value }))
                }
                rows={4}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#001F3F]/20"
                placeholder="About text in English..."
              />
            </div>
          </div>
        </div>

        {/* Booking Settings */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-xl font-bold text-[#001F3F] mb-6">
            Paramètres de réservation
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Durée par défaut (minutes)
              </label>
              <input
                type="number"
                value={settings.default_appointment_duration || '30'}
                onChange={(e) =>
                  setSettings((prev) => ({
                    ...prev,
                    default_appointment_duration: e.target.value,
                  }))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#001F3F]/20"
                min="15"
                step="15"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Prix par défaut (€)
              </label>
              <input
                type="number"
                value={settings.default_consultation_price || '0'}
                onChange={(e) =>
                  setSettings((prev) => ({
                    ...prev,
                    default_consultation_price: e.target.value,
                  }))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#001F3F]/20"
                min="0"
                step="10"
              />
            </div>
          </div>
        </div>

        {/* Save Button */}
        <div className="flex justify-end">
          <button
            type="submit"
            disabled={saving}
            className="flex items-center gap-2 px-6 py-3 bg-[#001F3F] text-white rounded-lg hover:bg-[#003366] transition-colors disabled:opacity-50"
          >
            {saving ? (
              <>
                <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                Enregistrement...
              </>
            ) : (
              <>
                <Save className="h-5 w-5" />
                Enregistrer les paramètres
              </>
            )}
          </button>
        </div>
      </form>
    </div>
  );
}
