import './globals.css';
import Script from 'next/script';

export const metadata = {
  title: 'Business Ascension OS · Cockpit',
  description: 'Cockpit unifié Business Ascension™.',
};

export default function RootLayout({ children }) {
  return (
    <html lang="fr">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400..800;1,400..600&family=Hanken+Grotesk:wght@300;400;500;600;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body>
        <div className="mesh" />
        {children}
        <Script src="https://fast.wistia.com/player.js" strategy="afterInteractive" />
        <Script src="https://fast.wistia.com/embed/zy7jxmz90n.js" type="module" strategy="afterInteractive" />
        <Script src="https://fast.wistia.com/embed/4hlujiu0vh.js" type="module" strategy="afterInteractive" />
        <Script src="https://fast.wistia.com/embed/7hjg9wvzup.js" type="module" strategy="afterInteractive" />
        <Script src="https://fast.wistia.com/embed/q9d8hwqua3.js" type="module" strategy="afterInteractive" />
      </body>
    </html>
  );
}
