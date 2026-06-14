'use client';
import { useState } from 'react';
import { createClient } from '@/lib/supabase/client';

export default function Login() {
  const [email, setEmail] = useState('');
  const [msg, setMsg] = useState('');
  const [loading, setLoading] = useState(false);

  async function sendLink(e) {
    e.preventDefault();
    setLoading(true);
    setMsg('');
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: { emailRedirectTo: `${window.location.origin}/auth/callback` },
    });
    setLoading(false);
    setMsg(
      error
        ? 'Erreur : ' + error.message
        : 'Lien envoyé. Va voir ta boîte mail et clique pour entrer.'
    );
  }

  return (
    <div className="login-wrap">
      <div className="login-card">
        <div className="mark">B</div>
        <h1>Business Ascension OS</h1>
        <p>Connexion au cockpit. Un lien magique arrive par email.</p>
        <form onSubmit={sendLink}>
          <input
            type="email"
            required
            placeholder="ton@email.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
          <button className="btn btn-gold" disabled={loading}>
            {loading ? 'Envoi…' : 'Recevoir mon lien →'}
          </button>
        </form>
        {msg && <div className="msg">{msg}</div>}
      </div>
    </div>
  );
}
