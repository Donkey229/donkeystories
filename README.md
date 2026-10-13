# Donkey Stories – hemsidan

Statisk sida (HTML, CSS, JS, bilder och egna typsnitt). Ingen databas, inget byggsteg.

## Lägga upp på servern

1. Kör `sh server/paketera.sh`. Du får mappen `dist/` och `donkeystories-server.zip`
   med exakt de filer som ska upp.
2. Ladda upp **innehållet** i `dist/` (inte själva mappen) till webbroten
   (oftast `public_html/` eller `www/`) via webbhotellets filhanterare, FTP eller SFTP.
   Tänk på att `.htaccess` är en dold fil: slå på "visa dolda filer" i FTP-programmet.
3. Öppna sidan och prova en adress som inte finns, t.ex. `/test`. Då ska 404-sidan visas.

## Vilken server?

- **Webbhotell med Apache** (Loopia, One.com, Binero m.fl.): `.htaccess` sköter allt –
  404-sida, cache, komprimering och säkerhetsrubriker.
- **Egen server med nginx**: använd `server/nginx.conf` som mall (instruktioner finns i filen).
- **GitHub Pages**: fungerar som det är (`.nojekyll` gör att filerna visas oförändrade).

## När domänen och SSL är klara

- Slå på https-omdirigeringen och `Strict-Transport-Security` i `.htaccess`
  (raderna är bortkommenterade).
- `og:image` i `index.html` pekar redan på `https://donkeystories.com/img/logo.jpg`.

## När YouTube-videon bäddas in

Säkerhetsregeln (Content-Security-Policy) tillåter bara den egna servern.
Lägg till `frame-src https://www.youtube-nocookie.com` i både `.htaccess` och `server/nginx.conf`.
