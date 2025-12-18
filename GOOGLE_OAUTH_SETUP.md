# Configuration Google OAuth - Sygma Consult

## ⚠️ ERREUR ACTUELLE: `redirect_uri_mismatch`

Cette erreur signifie que les URIs de redirection ne sont pas configurés dans Google Cloud Console.

## 🚀 SOLUTION RAPIDE (5 minutes)

### Étape 1: Ouvrir Google Cloud Console
👉 **https://console.cloud.google.com/apis/credentials**

### Étape 2: Éditer votre Client OAuth 2.0
1. Dans la liste, trouvez votre Client OAuth 2.0
2. Cliquez sur le nom pour éditer

### Étape 3: Ajouter les "Authorized redirect URIs"

Ajoutez ces 2 URIs EXACTEMENT comme indiqué:

**Pour le développement local:**
```
http://localhost:3000/api/auth/google/callback
```

**Pour la production (domaine principal):**
```
https://sygmaconsult.com/api/auth/google/callback
```

**Pour Vercel (optionnel):**
```
https://sygmaconsult.vercel.app/api/auth/google/callback
```

### Étape 4: Ajouter les "Authorized JavaScript origins"

Ajoutez ces origins:

```
http://localhost:3000
```

```
https://sygmaconsult.com
```

```
https://sygmaconsult.vercel.app
```

### Étape 5: Sauvegarder

Cliquez sur **"SAVE"** en bas de la page.

### Étape 6: Activer les APIs

Allez sur: **https://console.cloud.google.com/apis/library**

Recherchez et activez:
- ✅ Google Calendar API
- ✅ Google Drive API
- ✅ Google Sheets API
- ✅ Google Docs API

### Étape 7: Variables d'Environnement Vercel

Dans votre dashboard Vercel, ajoutez ces variables d'environnement:

```
GOOGLE_CLIENT_ID=votre_client_id_ici
GOOGLE_CLIENT_SECRET=votre_client_secret_ici
GOOGLE_REDIRECT_URI=https://sygmaconsult.com/api/auth/google/callback
NEXT_PUBLIC_GOOGLE_CLIENT_ID=votre_client_id_ici
```

*Note: Les vraies valeurs sont dans votre fichier .env.local*

## 📝 Configuration de l'Écran de Consentement

1. Allez dans **OAuth consent screen**
2. Configurez:
   - **Application name**: Sygma Consult
   - **User support email**: contact@sygma-consult.com
   - **Authorized domains**:
     - sygmaconsult.com
     - sygmaconsult.vercel.app
   - **Developer contact**: contact@sygma-consult.com

3. Ajoutez les **Scopes** suivants:
   - `https://www.googleapis.com/auth/calendar`
   - `https://www.googleapis.com/auth/calendar.events`
   - `https://www.googleapis.com/auth/drive`
   - `https://www.googleapis.com/auth/drive.file`
   - `https://www.googleapis.com/auth/spreadsheets`
   - `https://www.googleapis.com/auth/documents`
   - `https://www.googleapis.com/auth/userinfo.email`
   - `https://www.googleapis.com/auth/userinfo.profile`

## ✅ Test

1. Attendez 1-2 minutes (propagation)
2. Allez sur: `http://localhost:3000/admin/settings`
3. Cliquez sur "Connect with Google"
4. Autorisez les permissions

## ❌ Dépannage

### Erreur: `redirect_uri_mismatch`
- Vérifiez que les URIs sont EXACTEMENT comme indiqués ci-dessus
- Pas d'espaces avant/après
- Attendez quelques minutes après la modification

### Erreur: `access_denied`
- Vérifiez l'écran de consentement OAuth
- Assurez-vous que tous les scopes sont ajoutés

### Erreur: `API not enabled`
- Activez toutes les APIs mentionnées dans l'Étape 6

## 📞 Support

Contact: contact@sygma-consult.com
