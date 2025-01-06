# Crypto Coins Price Library

Une bibliothèque simple pour récupérer les prix de cryptomonnaies en fonction de paires (ex. : BTC/USD) à l'aide de l'API de CoinGecko.

---

## 📦 Installation

1. Clonez le projet depuis GitHub (ou téléchargez les fichiers) :
   ```bash
   git clone https://github.com/username/crypto-coins-price-lib.git
   cd crypto-coins-price-lib
   ```

2. Installez les dépendances :
   ```bash
   npm install
   ```

3. Compilez la bibliothèque en JavaScript :
   ```bash
   npm run res:build
   ```

4. Votre bibliothèque est prête à être utilisée !

---

## 🛠️ Utilisation

### Chargement de la bibliothèque

Dans votre projet JavaScript/TypeScript, importez la bibliothèque après l'installation.

Exemple d'importation dans un fichier JS/TS :
```javascript
const { createClient, getPriceWithPromise, getPrice } = require("./path/to/compiled-lib");
```

---

### Exemples d'utilisation

#### 1. Créer un client

Avant de récupérer des prix, créez un client. Vous pouvez utiliser les paramètres par défaut ou fournir vos propres configurations.

```javascript
const client = createClient();

// Exemple avec configuration personnalisée
const customClient = createClient({
  baseUrl: "https://api.coingecko.com/api/v3",
  timeout: 10000, // 10 secondes
  retryAttempts: 5, // 5 tentatives en cas d'échec
});
```

---

#### 2. Récupérer une paire avec des promesses

Récupérez les prix d'une paire (ex. : `BTC/USD`) en utilisant `getPriceWithPromise`.

```javascript
getPriceWithPromise(client, "bitcoin", "usd")
  .then((result) => {
    if (result.Ok) {
      console.log("Success:", result.Ok); // Affiche les détails de la paire
    } else {
      console.error("Error:", result.Error); // Affiche l'erreur
    }
  })
  .catch((err) => {
    console.error("Unexpected Error:", err);
  });
```

---

#### 3. Récupérer une paire avec des callbacks

Si vous préférez utiliser des callbacks :

```javascript
getPrice(client, "bitcoin", "usd", 
  (data) => {
    console.log("Success:", data);
  },
  (error) => {
    console.error("Error:", error);
  });
```

---

## ⚙️ Options de configuration

Lors de la création du client, vous pouvez personnaliser les paramètres suivants :

| Option          | Type    | Par défaut                            | Description                              |
|------------------|---------|---------------------------------------|------------------------------------------|
| `baseUrl`        | string  | `https://api.coingecko.com/api/v3`    | URL de base pour les appels API.         |
| `timeout`        | int     | `5000` (5 secondes)                  | Temps maximum pour attendre une réponse. |
| `retryAttempts`  | int     | `3`                                  | Nombre de tentatives en cas d'échec.     |

---

## 🌟 Utilisation avec ReScript

Si vous travaillez directement avec ReScript, voici un exemple d'utilisation dans un fichier `.res` :

```rescript
let client = PriceLib.createClient()

PriceLib.getPriceWithPromise(client, "bitcoin", "usd")
->Promise.then(result => {
  switch result {
  | Ok(data) => Js.log({"message": "Success", "data": data})
  | Error(error) => Js.log({"message": "Error", "error": error})
  }
  Promise.resolve()
})
```

#### Installation et compilation

1. Assurez-vous que les dépendances ReScript sont installées :
   ```bash
   npm install rescript @rescript/core rescript-webapi
   ```

2. Lancez la commande pour compiler :
   ```bash
   npm run res:build
   ```

---

## 🚀 Fonctionnalités à venir

- Support pour plusieurs paires en un seul appel.
- Gestion avancée du cache.
- Prise en charge de nouvelles API.

---

## 📄 Licence

Ce projet est sous licence [MIT](LICENSE).

---