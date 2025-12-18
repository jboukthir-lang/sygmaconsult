'use client'

import { useState, useEffect } from 'react'
import { Calendar, Clock, Plus, Edit, Trash2, Check, X, AlertCircle, Settings } from 'lucide-react'
import { supabase } from '@/lib/supabase'
import { useLanguage } from '@/context/LanguageContext'

interface AppointmentType {
  id: string
  name_ar: string
  name_fr: string
  name_en: string
  description_ar: string | null
  description_fr: string | null
  description_en: string | null
  duration: number
  color: string
  price: number
  is_active: boolean
}

interface CalendarSettings {
  id: string
  monday_enabled: boolean
  tuesday_enabled: boolean
  wednesday_enabled: boolean
  thursday_enabled: boolean
  friday_enabled: boolean
  saturday_enabled: boolean
  sunday_enabled: boolean
  monday_start: string
  monday_end: string
  tuesday_start: string
  tuesday_end: string
  wednesday_start: string
  wednesday_end: string
  thursday_start: string
  thursday_end: string
  friday_start: string
  friday_end: string
  saturday_start: string
  saturday_end: string
  sunday_start: string
  sunday_end: string
  lunch_break_enabled: boolean
  lunch_break_start: string
  lunch_break_end: string
  slot_duration: number
  max_advance_booking_days: number
  min_advance_booking_hours: number
  allow_weekend_booking: boolean
  require_admin_approval: boolean
  send_confirmation_email: boolean
  send_reminder_email: boolean
  reminder_hours_before: number
}

interface Appointment {
  id: string
  title: string
  appointment_date: string
  start_time: string
  end_time: string
  client_name: string
  client_email: string
  client_phone: string
  status: string
  appointment_types: AppointmentType | null
}

export default function CalendarPage() {
  const { t, language } = useLanguage()
  const [activeTab, setActiveTab] = useState<'appointments' | 'types' | 'settings'>('appointments')
  const [appointments, setAppointments] = useState<Appointment[]>([])
  const [appointmentTypes, setAppointmentTypes] = useState<AppointmentType[]>([])
  const [settings, setSettings] = useState<CalendarSettings | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState<{ type: 'success' | 'error', text: string } | null>(null)

  const daysOfWeek = [
    { key: 'monday', label: t.adminCalendar.settings.working_hours.title }, // This is a bit of a hack, but let's use the object structure
  ]

  // Re-defining daysOfWeek mapping to use translation keys instead of hardcoded labels
  const localizedDays = [
    { key: 'monday', label: language === 'ar' ? 'الإثنين' : language === 'fr' ? 'Lundi' : 'Monday' },
    { key: 'tuesday', label: language === 'ar' ? 'الثلاثاء' : language === 'fr' ? 'Mardi' : 'Tuesday' },
    { key: 'wednesday', label: language === 'ar' ? 'الأربعاء' : language === 'fr' ? 'Mercredi' : 'Wednesday' },
    { key: 'thursday', label: language === 'ar' ? 'الخميس' : language === 'fr' ? 'Jeudi' : 'Thursday' },
    { key: 'friday', label: language === 'ar' ? 'الجمعة' : language === 'fr' ? 'Vendredi' : 'Friday' },
    { key: 'saturday', label: language === 'ar' ? 'السبت' : language === 'fr' ? 'Samedi' : 'Saturday' },
    { key: 'sunday', label: language === 'ar' ? 'الأحد' : language === 'fr' ? 'Dimanche' : 'Sunday' }
  ]

  useEffect(() => {
    fetchData()
  }, [activeTab])

  async function fetchData() {
    setLoading(true)
    try {
      if (activeTab === 'appointments') {
        const { data, error } = await supabase
          .from('appointments')
          .select(`
            *,
            appointment_types (*)
          `)
          .gte('appointment_date', new Date().toISOString().split('T')[0])
          .order('appointment_date', { ascending: true })
          .order('start_time', { ascending: true })

        if (error) throw error
        setAppointments(data || [])
      } else if (activeTab === 'types') {
        const { data, error } = await supabase
          .from('appointment_types')
          .select('*')
          .order('duration', { ascending: true })

        if (error) throw error
        setAppointmentTypes(data || [])
      } else if (activeTab === 'settings') {
        const { data, error } = await supabase
          .from('calendar_settings')
          .select('*')
          .single()

        if (error) throw error
        setSettings(data)
      }
    } catch (error) {
      console.error('Error fetching data:', error)
      showMessage('error', t.adminCalendar.messages.load_error)
    } finally {
      setLoading(false)
    }
  }

  async function saveSettings() {
    if (!settings) return

    setSaving(true)
    try {
      const { error } = await supabase
        .from('calendar_settings')
        .update(settings)
        .eq('id', settings.id)

      if (error) throw error

      showMessage('success', t.adminCalendar.messages.save_success)
    } catch (error) {
      console.error('Error saving settings:', error)
      showMessage('error', t.adminCalendar.messages.save_error)
    } finally {
      setSaving(false)
    }
  }

  async function updateAppointmentStatus(id: string, status: string) {
    try {
      const { error } = await supabase
        .from('appointments')
        .update({ status })
        .eq('id', id)

      if (error) throw error

      showMessage('success', t.adminCalendar.messages.status_updated)
      fetchData()
    } catch (error) {
      console.error('Error updating appointment:', error)
      showMessage('error', t.adminCalendar.messages.status_error)
    }
  }

  async function toggleAppointmentType(id: string, isActive: boolean) {
    try {
      const { error } = await supabase
        .from('appointment_types')
        .update({ is_active: !isActive })
        .eq('id', id)

      if (error) throw error

      showMessage('success', t.adminCalendar.messages.type_updated)
      fetchData()
    } catch (error) {
      console.error('Error updating appointment type:', error)
      showMessage('error', t.adminCalendar.messages.type_error)
    }
  }

  function showMessage(type: 'success' | 'error', text: string) {
    setMessage({ type, text })
    setTimeout(() => setMessage(null), 5000)
  }

  function getStatusBadge(status: string) {
    const badges = {
      pending: { bg: 'bg-yellow-100', text: 'text-yellow-800', label: t.adminCalendar.appointments.status.pending },
      confirmed: { bg: 'bg-green-100', text: 'text-green-800', label: t.adminCalendar.appointments.status.confirmed },
      cancelled: { bg: 'bg-red-100', text: 'text-red-800', label: t.adminCalendar.appointments.status.cancelled },
      completed: { bg: 'bg-blue-100', text: 'text-blue-800', label: t.adminCalendar.appointments.status.completed },
      no_show: { bg: 'bg-gray-100', text: 'text-gray-800', label: t.adminCalendar.appointments.status.no_show }
    }

    const badge = badges[status as keyof typeof badges] || badges.pending

    return (
      <span className={`px-2 py-1 text-xs font-medium rounded-full ${badge.bg} ${badge.text}`}>
        {badge.label}
      </span>
    )
  }

  return (
    <div className="p-6">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900">{t.adminCalendar.title}</h1>
        <p className="text-gray-600 mt-2">{t.adminCalendar.subtitle}</p>
      </div>

      {/* Message */}
      {message && (
        <div className={`mb-4 p-4 rounded-lg ${message.type === 'success' ? 'bg-green-50 text-green-800' : 'bg-red-50 text-red-800'}`}>
          <div className="flex items-center gap-2">
            <AlertCircle className="w-5 h-5" />
            <span>{message.text}</span>
          </div>
        </div>
      )}

      {/* Tabs */}
      <div className="mb-6 border-b border-gray-200">
        <nav className="flex space-x-8 space-x-reverse">
          <button
            onClick={() => setActiveTab('appointments')}
            className={`pb-4 px-1 border-b-2 font-medium text-sm ${activeTab === 'appointments'
              ? 'border-blue-500 text-blue-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
          >
            <div className="flex items-center gap-2">
              <Calendar className="w-5 h-5" />
              {t.adminCalendar.tabs.appointments}
            </div>
          </button>
          <button
            onClick={() => setActiveTab('types')}
            className={`pb-4 px-1 border-b-2 font-medium text-sm ${activeTab === 'types'
              ? 'border-blue-500 text-blue-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
          >
            <div className="flex items-center gap-2">
              <Plus className="w-5 h-5" />
              {t.adminCalendar.tabs.types}
            </div>
          </button>
          <button
            onClick={() => setActiveTab('settings')}
            className={`pb-4 px-1 border-b-2 font-medium text-sm ${activeTab === 'settings'
              ? 'border-blue-500 text-blue-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
          >
            <div className="flex items-center gap-2">
              <Settings className="w-5 h-5" />
              {t.adminCalendar.tabs.settings}
            </div>
          </button>
        </nav>
      </div>

      {loading ? (
        <div className="text-center py-12">
          <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          <p className="mt-2 text-gray-600">{t.adminCalendar.messages.loading}</p>
        </div>
      ) : (
        <>
          {/* Appointments Tab */}
          {activeTab === 'appointments' && (
            <div className="bg-white rounded-lg shadow">
              <div className="p-6">
                <h2 className="text-xl font-semibold mb-4">{t.adminCalendar.appointments.title}</h2>
                {appointments.length === 0 ? (
                  <p className="text-gray-500 text-center py-8">{t.adminCalendar.appointments.empty}</p>
                ) : (
                  <div className="overflow-x-auto">
                    <table className="w-full">
                      <thead>
                        <tr className="border-b">
                          <th className="text-right py-3 px-4">{t.adminCalendar.appointments.table.date}</th>
                          <th className="text-right py-3 px-4">{t.adminCalendar.appointments.table.time}</th>
                          <th className="text-right py-3 px-4">{t.adminCalendar.appointments.table.title}</th>
                          <th className="text-right py-3 px-4">{t.adminCalendar.appointments.table.client}</th>
                          <th className="text-right py-3 px-4">{t.adminCalendar.appointments.table.phone}</th>
                          <th className="text-right py-3 px-4">{t.adminCalendar.appointments.table.type}</th>
                          <th className="text-right py-3 px-4">{t.adminCalendar.appointments.table.status}</th>
                          <th className="text-right py-3 px-4">{t.adminCalendar.appointments.table.actions}</th>
                        </tr>
                      </thead>
                      <tbody>
                        {appointments.map((apt) => (
                          <tr key={apt.id} className="border-b hover:bg-gray-50">
                            <td className="py-3 px-4">{new Date(apt.appointment_date).toLocaleDateString(language === 'ar' ? 'ar-TN' : language === 'fr' ? 'fr-FR' : 'en-US')}</td>
                            <td className="py-3 px-4">{apt.start_time} - {apt.end_time}</td>
                            <td className="py-3 px-4">{apt.title}</td>
                            <td className="py-3 px-4">{apt.client_name}</td>
                            <td className="py-3 px-4 text-sm text-gray-600">{apt.client_phone}</td>
                            <td className="py-3 px-4">
                              {apt.appointment_types && (
                                <span
                                  className="px-2 py-1 text-xs rounded"
                                  style={{ backgroundColor: apt.appointment_types.color + '20', color: apt.appointment_types.color }}
                                >
                                  {apt.appointment_types[`name_${language}` as keyof AppointmentType]}
                                </span>
                              )}
                            </td>
                            <td className="py-3 px-4">{getStatusBadge(apt.status)}</td>
                            <td className="py-3 px-4">
                              <div className="flex gap-2">
                                {apt.status === 'pending' && (
                                  <>
                                    <button
                                      onClick={() => updateAppointmentStatus(apt.id, 'confirmed')}
                                      className="text-green-600 hover:text-green-800"
                                      title={t.adminCalendar.appointments.actions.confirm}
                                    >
                                      <Check className="w-5 h-5" />
                                    </button>
                                    <button
                                      onClick={() => updateAppointmentStatus(apt.id, 'cancelled')}
                                      className="text-red-600 hover:text-red-800"
                                      title={t.adminCalendar.appointments.actions.cancel}
                                    >
                                      <X className="w-5 h-5" />
                                    </button>
                                  </>
                                )}
                                {apt.status === 'confirmed' && (
                                  <button
                                    onClick={() => updateAppointmentStatus(apt.id, 'completed')}
                                    className="text-blue-600 hover:text-blue-800"
                                    title={t.adminCalendar.appointments.actions.complete}
                                  >
                                    <Check className="w-5 h-5" />
                                  </button>
                                )}
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Appointment Types Tab */}
          {activeTab === 'types' && (
            <div className="bg-white rounded-lg shadow">
              <div className="p-6">
                <div className="flex justify-between items-center mb-4">
                  <h2 className="text-xl font-semibold">{t.adminCalendar.types.title}</h2>
                  <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2">
                    <Plus className="w-5 h-5" />
                    {t.adminCalendar.types.add_new}
                  </button>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {appointmentTypes.map((type) => (
                    <div key={type.id} className="border rounded-lg p-4">
                      <div className="flex justify-between items-start mb-3">
                        <div className="flex items-center gap-2">
                          <div
                            className="w-4 h-4 rounded-full"
                            style={{ backgroundColor: type.color }}
                          ></div>
                          <h3 className="font-semibold">{type[`name_${language}` as keyof AppointmentType]}</h3>
                        </div>
                        <button
                          onClick={() => toggleAppointmentType(type.id, type.is_active)}
                          className={`text-sm px-2 py-1 rounded ${type.is_active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                            }`}
                        >
                          {type.is_active ? t.adminCalendar.types.active : t.adminCalendar.types.inactive}
                        </button>
                      </div>
                      <p className="text-sm text-gray-600 mb-3">{type[`description_${language}` as keyof AppointmentType]}</p>
                      <div className="flex justify-between text-sm">
                        <span className="text-gray-600">{t.adminCalendar.types.duration}: {type.duration} {language === 'ar' ? 'دقيقة' : 'min'}</span>
                        <span className="text-gray-600">{t.adminCalendar.types.price}: {type.price} €</span>
                      </div>
                      <div className="mt-3 flex gap-2">
                        <button className="text-blue-600 hover:text-blue-800">
                          <Edit className="w-4 h-4" />
                        </button>
                        <button className="text-red-600 hover:text-red-800">
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Settings Tab */}
          {activeTab === 'settings' && settings && (
            <div className="bg-white rounded-lg shadow">
              <div className="p-6">
                <h2 className="text-xl font-semibold mb-6">{t.adminCalendar.settings.title}</h2>

                {/* Working Days */}
                <div className="mb-8">
                  <h3 className="text-lg font-medium mb-4">{t.adminCalendar.settings.working_hours.title}</h3>
                  <div className="space-y-4">
                    {localizedDays.map((day) => {
                      const enabledKey = `${day.key}_enabled` as keyof CalendarSettings
                      const startKey = `${day.key}_start` as keyof CalendarSettings
                      const endKey = `${day.key}_end` as keyof CalendarSettings

                      return (
                        <div key={day.key} className="flex items-center gap-4 p-4 border rounded-lg">
                          <input
                            type="checkbox"
                            checked={settings[enabledKey] as boolean}
                            onChange={(e) => setSettings({ ...settings, [enabledKey]: e.target.checked })}
                            className="w-5 h-5"
                          />
                          <span className="w-24 font-medium">{day.label}</span>
                          {settings[enabledKey] && (
                            <>
                              <input
                                type="time"
                                value={settings[startKey] as string}
                                onChange={(e) => setSettings({ ...settings, [startKey]: e.target.value })}
                                className="border rounded px-3 py-2"
                              />
                              <span>{t.adminCalendar.settings.working_hours.to}</span>
                              <input
                                type="time"
                                value={settings[endKey] as string}
                                onChange={(e) => setSettings({ ...settings, [endKey]: e.target.value })}
                                className="border rounded px-3 py-2"
                              />
                            </>
                          )}
                        </div>
                      )
                    })}
                  </div>
                </div>

                {/* Lunch Break */}
                <div className="mb-8">
                  <h3 className="text-lg font-medium mb-4">{t.adminCalendar.settings.lunch_break.title}</h3>
                  <div className="flex items-center gap-4 p-4 border rounded-lg">
                    <input
                      type="checkbox"
                      checked={settings.lunch_break_enabled}
                      onChange={(e) => setSettings({ ...settings, lunch_break_enabled: e.target.checked })}
                      className="w-5 h-5"
                    />
                    <span className="font-medium">{t.adminCalendar.settings.lunch_break.enable}</span>
                    {settings.lunch_break_enabled && (
                      <>
                        <input
                          type="time"
                          value={settings.lunch_break_start}
                          onChange={(e) => setSettings({ ...settings, lunch_break_start: e.target.value })}
                          className="border rounded px-3 py-2"
                        />
                        <span>{t.adminCalendar.settings.working_hours.to}</span>
                        <input
                          type="time"
                          value={settings.lunch_break_end}
                          onChange={(e) => setSettings({ ...settings, lunch_break_end: e.target.value })}
                          className="border rounded px-3 py-2"
                        />
                      </>
                    )}
                  </div>
                </div>

                {/* General Settings */}
                <div className="mb-8">
                  <h3 className="text-lg font-medium mb-4">{t.adminCalendar.settings.general.title}</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-2">{t.adminCalendar.settings.general.slot_duration}</label>
                      <input
                        type="number"
                        value={settings.slot_duration}
                        onChange={(e) => setSettings({ ...settings, slot_duration: parseInt(e.target.value) })}
                        className="w-full border rounded px-3 py-2"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium mb-2">{t.adminCalendar.settings.general.max_days}</label>
                      <input
                        type="number"
                        value={settings.max_advance_booking_days}
                        onChange={(e) => setSettings({ ...settings, max_advance_booking_days: parseInt(e.target.value) })}
                        className="w-full border rounded px-3 py-2"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium mb-2">{t.adminCalendar.settings.general.min_hours}</label>
                      <input
                        type="number"
                        value={settings.min_advance_booking_hours}
                        onChange={(e) => setSettings({ ...settings, min_advance_booking_hours: parseInt(e.target.value) })}
                        className="w-full border rounded px-3 py-2"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium mb-2">{t.adminCalendar.settings.general.reminder_hours}</label>
                      <input
                        type="number"
                        value={settings.reminder_hours_before}
                        onChange={(e) => setSettings({ ...settings, reminder_hours_before: parseInt(e.target.value) })}
                        className="w-full border rounded px-3 py-2"
                      />
                    </div>
                  </div>
                </div>

                {/* Email Settings */}
                <div className="mb-8">
                  <h3 className="text-lg font-medium mb-4">{t.adminCalendar.settings.email.title}</h3>
                  <div className="space-y-3">
                    <label className="flex items-center gap-3">
                      <input
                        type="checkbox"
                        checked={settings.send_confirmation_email}
                        onChange={(e) => setSettings({ ...settings, send_confirmation_email: e.target.checked })}
                        className="w-5 h-5"
                      />
                      <span>{t.adminCalendar.settings.email.confirmation}</span>
                    </label>
                    <label className="flex items-center gap-3">
                      <input
                        type="checkbox"
                        checked={settings.send_reminder_email}
                        onChange={(e) => setSettings({ ...settings, send_reminder_email: e.target.checked })}
                        className="w-5 h-5"
                      />
                      <span>{t.adminCalendar.settings.email.reminder}</span>
                    </label>
                    <label className="flex items-center gap-3">
                      <input
                        type="checkbox"
                        checked={settings.require_admin_approval}
                        onChange={(e) => setSettings({ ...settings, require_admin_approval: e.target.checked })}
                        className="w-5 h-5"
                      />
                      <span>{t.adminCalendar.settings.email.approval}</span>
                    </label>
                  </div>
                </div>

                {/* Save Button */}
                <div className="flex justify-end">
                  <button
                    onClick={saveSettings}
                    disabled={saving}
                    className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                  >
                    {saving ? (
                      <>
                        <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                        {t.adminCalendar.settings.save.saving}
                      </>
                    ) : (
                      <>
                        <Check className="w-5 h-5" />
                        {t.adminCalendar.settings.save.button}
                      </>
                    )}
                  </button>
                </div>
              </div>
            </div>
          )}
        </>
      )}
    </div>
  )
}
