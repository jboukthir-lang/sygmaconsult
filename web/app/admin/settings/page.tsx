'use client';

import { useState, useEffect } from 'react';
import { useSearchParams } from 'next/navigation';

export default function AdminSettings() {
  const searchParams = useSearchParams();
  const [isGoogleConnected, setIsGoogleConnected] = useState(false);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState('');

  useEffect(() => {
    // Check if Google is connected by checking cookie
    fetch('/api/auth/google/status')
      .then(res => res.json())
      .then(data => {
        setIsGoogleConnected(data.connected);
        setLoading(false);
      })
      .catch(() => {
        setLoading(false);
      });

    // Check for success/error messages from OAuth redirect
    const googleConnected = searchParams.get('google_connected');
    const error = searchParams.get('error');

    if (googleConnected === 'true') {
      setMessage('Google account connected successfully!');
      setIsGoogleConnected(true);
    } else if (error) {
      setMessage(`Error: ${error}`);
    }
  }, [searchParams]);

  const handleConnectGoogle = async () => {
    // Get auth URL from API endpoint
    try {
      const res = await fetch('/api/auth/google/auth-url');
      const data = await res.json();
      window.location.href = data.authUrl;
    } catch (error) {
      setMessage('Failed to get Google auth URL');
    }
  };

  const handleDisconnectGoogle = async () => {
    try {
      const res = await fetch('/api/auth/google/disconnect', {
        method: 'POST',
      });

      if (res.ok) {
        setIsGoogleConnected(false);
        setMessage('Google account disconnected');
      }
    } catch (error) {
      setMessage('Failed to disconnect Google account');
    }
  };

  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold mb-6 text-[#001F3F]">Settings</h1>

      {message && (
        <div className={`mb-4 p-4 rounded ${message.includes('Error') ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'}`}>
          {message}
        </div>
      )}

      <div className="bg-white rounded-lg shadow-md p-6 mb-6">
        <h2 className="text-xl font-semibold mb-4 text-[#001F3F]">Google Integration</h2>
        <p className="text-gray-600 mb-4">
          Connect your Google account to enable Calendar, Meet, Drive, Sheets, and Docs integrations.
        </p>

        {loading ? (
          <div className="text-gray-500">Loading...</div>
        ) : isGoogleConnected ? (
          <div>
            <div className="flex items-center mb-4">
              <svg className="w-6 h-6 text-green-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
              <span className="text-green-700 font-medium">Google Account Connected</span>
            </div>

            <div className="bg-gray-50 p-4 rounded mb-4">
              <h3 className="font-medium mb-2">Enabled Features:</h3>
              <ul className="space-y-1 text-sm text-gray-700">
                <li>✓ Google Calendar - Automatic event creation</li>
                <li>✓ Google Meet - Video conference links</li>
                <li>✓ Google Drive - File storage and sharing</li>
                <li>✓ Google Sheets - Data export</li>
                <li>✓ Google Docs - Contract generation</li>
              </ul>
            </div>

            <button
              onClick={handleDisconnectGoogle}
              className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition"
            >
              Disconnect Google Account
            </button>
          </div>
        ) : (
          <div>
            <div className="bg-yellow-50 border-l-4 border-yellow-400 p-4 mb-4">
              <p className="text-sm text-yellow-700">
                Google integration is not connected. Connect to enable advanced features.
              </p>
            </div>

            <button
              onClick={handleConnectGoogle}
              className="flex items-center px-6 py-3 bg-white border-2 border-gray-300 rounded-lg hover:bg-gray-50 transition shadow-sm"
            >
              <svg className="w-5 h-5 mr-3" viewBox="0 0 24 24">
                <path
                  fill="#4285F4"
                  d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                />
                <path
                  fill="#34A853"
                  d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                />
                <path
                  fill="#FBBC05"
                  d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                />
                <path
                  fill="#EA4335"
                  d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                />
              </svg>
              <span className="font-medium text-gray-700">Connect with Google</span>
            </button>
          </div>
        )}
      </div>

      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-xl font-semibold mb-4 text-[#001F3F]">System Information</h2>
        <div className="space-y-2 text-sm">
          <div className="flex justify-between">
            <span className="text-gray-600">Version:</span>
            <span className="font-medium">1.2.0-final</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-600">Environment:</span>
            <span className="font-medium">{process.env.NODE_ENV}</span>
          </div>
        </div>
      </div>
    </div>
  );
}
