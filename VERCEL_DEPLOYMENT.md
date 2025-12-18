# Vercel Deployment Instructions

## Configuration Vercel

Pour déployer correctement ce projet sur Vercel:

### 1. Root Directory
Dans les paramètres du projet Vercel:
- **Root Directory**: `web`
- Cela indique à Vercel que l'application Next.js est dans le dossier `web`

### 2. Build Settings
Vercel détectera automatiquement Next.js et utilisera:
- **Build Command**: `npm run build` (automatique)
- **Output Directory**: `.next` (automatique)
- **Install Command**: `npm install` (automatique)

### 3. Environment Variables
Assurez-vous d'ajouter dans Vercel Dashboard:
```
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SMTP_HOST=your_smtp_host
SMTP_PORT=587
SMTP_USER=your_email
SMTP_PASSWORD=your_password
ADMIN_EMAIL=your_admin_email
```

### 4. Alternative: Keep Root Directory Empty
Si vous ne pouvez pas changer Root Directory:
- Le fichier `package.json` à la racine s'occupera du build
- Il exécutera automatiquement: `cd web && npm install && npm run build`

## Troubleshooting

Si vous voyez l'erreur `routes-manifest.json not found`:
1. Allez dans Project Settings → General
2. Changez **Root Directory** à `web`
3. Redéployez

Ou:
1. Gardez Root Directory vide
2. Le système utilisera le package.json racine qui fait la redirection

## Structure du Projet
```
sygma-consult/
├── web/                  # Application Next.js
│   ├── app/
│   ├── components/
│   ├── lib/
│   ├── package.json
│   └── next.config.ts
├── package.json          # Délègue au web/
└── VERCEL_DEPLOYMENT.md
```
