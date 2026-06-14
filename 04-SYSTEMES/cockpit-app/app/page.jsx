import { redirect } from 'next/navigation';

// La racine renvoie vers le cockpit (le middleware gère l'auth).
export default function Home() {
  redirect('/cockpit');
}
