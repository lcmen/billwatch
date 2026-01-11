import React, { useState } from 'react';

// Simple router simulation
const useSimpleRouter = () => {
  const [page, setPage] = useState('home');
  return { page, navigate: setPage };
};

// Shared styles
const styles = {
  container: {
    minHeight: '100vh',
    backgroundColor: '#ffffff',
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
    color: '#1a1a1a',
    display: 'flex',
    flexDirection: 'column',
  },
  input: {
    width: '100%',
    padding: '12px 14px',
    border: '1px solid #ddd',
    borderRadius: 8,
    fontSize: 14,
    boxSizing: 'border-box',
    outline: 'none',
    transition: 'border-color 0.15s',
  },
  button: {
    width: '100%',
    padding: '12px 14px',
    backgroundColor: '#f97316',
    color: 'white',
    border: 'none',
    borderRadius: 8,
    fontSize: 14,
    fontWeight: 600,
    cursor: 'pointer',
    transition: 'background-color 0.15s',
  },
  link: {
    color: '#f97316',
    textDecoration: 'none',
    cursor: 'pointer',
    fontWeight: 500,
  },
  card: {
    width: '100%',
    maxWidth: 360,
    padding: 32,
    backgroundColor: 'white',
    borderRadius: 16,
    boxShadow: '0 25px 50px rgba(0,0,0,0.25)',
  },
  modalOverlay: {
    position: 'fixed',
    inset: 0,
    backgroundColor: 'rgba(0,0,0,0.5)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
    zIndex: 50,
  },
};

// Logo component
const Logo = ({ size = 'default', light = false }) => (
  <div style={{ 
    display: 'flex', 
    alignItems: 'center', 
    gap: 8,
    fontSize: size === 'large' ? 28 : 20,
    fontWeight: 700,
    color: light ? 'white' : '#1a1a1a',
  }}>
    <span style={{ 
      width: size === 'large' ? 36 : 28, 
      height: size === 'large' ? 36 : 28, 
      backgroundColor: '#f97316', 
      borderRadius: 8,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      color: 'white',
      fontSize: size === 'large' ? 18 : 14,
    }}>
      B
    </span>
    BillWatch
  </div>
);

// Login Modal
const LoginModal = ({ navigate, onClose }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    navigate('app');
  };

  return (
    <div style={styles.modalOverlay} onClick={onClose}>
      <div style={styles.card} onClick={e => e.stopPropagation()}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
          <h2 style={{ fontSize: 20, fontWeight: 600, margin: 0 }}>Log in</h2>
          <button 
            onClick={onClose}
            style={{ padding: 8, background: '#f5f5f5', border: 'none', borderRadius: 8, cursor: 'pointer', fontSize: 14 }}
          >
            ✕
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: 16 }}>
            <input
              type="email"
              placeholder="Email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              style={styles.input}
              required
            />
          </div>
          <div style={{ marginBottom: 8 }}>
            <input
              type="password"
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              style={styles.input}
              required
            />
          </div>
          <div style={{ textAlign: 'right', marginBottom: 20 }}>
            <span 
              onClick={() => navigate('forgot')}
              style={{ ...styles.link, fontSize: 13 }}
            >
              Forgot password?
            </span>
          </div>
          <button type="submit" style={styles.button}>
            Log in
          </button>
        </form>

        <p style={{ 
          textAlign: 'center', 
          marginTop: 20, 
          fontSize: 14, 
          color: '#666',
          marginBottom: 0
        }}>
          Don't have an account?{' '}
          <span onClick={() => navigate('signup')} style={styles.link}>
            Sign up
          </span>
        </p>
      </div>
    </div>
  );
};

// Sign Up Modal
const SignUpModal = ({ navigate, onClose }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    navigate('app');
  };

  return (
    <div style={styles.modalOverlay} onClick={onClose}>
      <div style={styles.card} onClick={e => e.stopPropagation()}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
          <h2 style={{ fontSize: 20, fontWeight: 600, margin: 0 }}>Create account</h2>
          <button 
            onClick={onClose}
            style={{ padding: 8, background: '#f5f5f5', border: 'none', borderRadius: 8, cursor: 'pointer', fontSize: 14 }}
          >
            ✕
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: 16 }}>
            <input
              type="email"
              placeholder="Email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              style={styles.input}
              required
            />
          </div>
          <div style={{ marginBottom: 20 }}>
            <input
              type="password"
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              style={styles.input}
              required
            />
          </div>
          <button type="submit" style={styles.button}>
            Create account
          </button>
        </form>

        <p style={{ 
          textAlign: 'center', 
          marginTop: 20, 
          fontSize: 14, 
          color: '#666',
          marginBottom: 0
        }}>
          Already have an account?{' '}
          <span onClick={() => navigate('login')} style={styles.link}>
            Log in
          </span>
        </p>
      </div>
    </div>
  );
};

// Forgot Password Modal
const ForgotPasswordModal = ({ navigate, onClose }) => {
  const [email, setEmail] = useState('');
  const [sent, setSent] = useState(false);

  const handleSubmit = (e) => {
    e.preventDefault();
    setSent(true);
  };

  return (
    <div style={styles.modalOverlay} onClick={onClose}>
      <div style={styles.card} onClick={e => e.stopPropagation()}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
          <h2 style={{ fontSize: 20, fontWeight: 600, margin: 0 }}>Reset password</h2>
          <button 
            onClick={onClose}
            style={{ padding: 8, background: '#f5f5f5', border: 'none', borderRadius: 8, cursor: 'pointer', fontSize: 14 }}
          >
            ✕
          </button>
        </div>

        <p style={{ fontSize: 14, color: '#666', margin: '0 0 20px 0' }}>
          {sent 
            ? 'Check your email for a reset link.'
            : 'Enter your email to receive a reset link.'
          }
        </p>

        {!sent ? (
          <form onSubmit={handleSubmit}>
            <div style={{ marginBottom: 20 }}>
              <input
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                style={styles.input}
                required
              />
            </div>
            <button type="submit" style={styles.button}>
              Send reset link
            </button>
          </form>
        ) : (
          <button 
            onClick={() => navigate('login')}
            style={styles.button}
          >
            Back to login
          </button>
        )}

        {!sent && (
          <p style={{ 
            textAlign: 'center', 
            marginTop: 20, 
            fontSize: 14, 
            color: '#666',
            marginBottom: 0
          }}>
            Remember your password?{' '}
            <span onClick={() => navigate('login')} style={styles.link}>
              Log in
            </span>
          </p>
        )}
      </div>
    </div>
  );
};

// Homepage with background
const HomePage = ({ navigate, modal, setModal }) => (
  <div style={{
    ...styles.container,
    backgroundImage: 'linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f97316 100%)',
    backgroundSize: 'cover',
    backgroundPosition: 'center',
    position: 'relative',
  }}>
    {/* Subtle pattern overlay */}
    <div style={{
      position: 'absolute',
      inset: 0,
      backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.05'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
      pointerEvents: 'none',
    }} />

    {/* Nav */}
    <nav style={{ 
      padding: '16px 24px', 
      display: 'flex', 
      justifyContent: 'space-between', 
      alignItems: 'center',
      position: 'relative',
      zIndex: 10,
    }}>
      <Logo light />
      <div style={{ display: 'flex', gap: 12 }}>
        <button 
          onClick={() => setModal('login')}
          style={{ 
            padding: '8px 16px', 
            backgroundColor: 'rgba(255,255,255,0.15)', 
            border: '1px solid rgba(255,255,255,0.3)', 
            borderRadius: 8, 
            fontSize: 14,
            fontWeight: 500,
            color: 'white',
            cursor: 'pointer',
            backdropFilter: 'blur(10px)',
          }}
        >
          Log in
        </button>
        <button 
          onClick={() => setModal('signup')}
          style={{ 
            padding: '8px 16px',
            backgroundColor: 'white',
            border: 'none',
            borderRadius: 8, 
            fontSize: 14,
            fontWeight: 600,
            color: '#1a1a1a',
            cursor: 'pointer',
          }}
        >
          Sign up
        </button>
      </div>
    </nav>

    {/* Hero */}
    <main style={{ 
      flex: 1, 
      display: 'flex', 
      flexDirection: 'column',
      alignItems: 'center', 
      justifyContent: 'center',
      padding: 24,
      textAlign: 'center',
      position: 'relative',
      zIndex: 10,
    }}>
      <h1 style={{ 
        fontSize: 48, 
        fontWeight: 700, 
        marginBottom: 16,
        margin: '0 0 16px 0',
        color: 'white',
        textShadow: '0 2px 20px rgba(0,0,0,0.2)',
        lineHeight: 1.2,
      }}>
        Track your bills,<br />never miss a payment
      </h1>
      <p style={{ 
        fontSize: 18, 
        color: 'rgba(255,255,255,0.9)', 
        marginBottom: 32,
        maxWidth: 420,
        margin: '0 0 32px 0',
      }}>
        Simple calendar view for all your recurring bills and subscriptions.
      </p>
      <button 
        onClick={() => setModal('signup')}
        style={{ 
          padding: '16px 36px',
          backgroundColor: 'white',
          border: 'none',
          borderRadius: 10, 
          fontSize: 16,
          fontWeight: 600,
          color: '#1a1a1a',
          cursor: 'pointer',
          boxShadow: '0 4px 20px rgba(0,0,0,0.2)',
        }}
      >
        Get started — it's free
      </button>
    </main>

    {/* Footer */}
    <footer style={{ 
      padding: '16px 24px', 
      textAlign: 'center',
      color: 'rgba(255,255,255,0.6)',
      fontSize: 13,
      position: 'relative',
      zIndex: 10,
    }}>
      © 2026 BillWatch
    </footer>

    {/* Modals */}
    {modal === 'login' && (
      <LoginModal navigate={navigate} onClose={() => setModal(null)} />
    )}
    {modal === 'signup' && (
      <SignUpModal navigate={navigate} onClose={() => setModal(null)} />
    )}
    {modal === 'forgot' && (
      <ForgotPasswordModal navigate={navigate} onClose={() => setModal(null)} />
    )}
  </div>
);

// Placeholder App Page (calendar would go here)
const AppPage = ({ navigate }) => (
  <div style={{ 
    ...styles.container, 
    alignItems: 'center', 
    justifyContent: 'center',
    padding: 24,
  }}>
    <div style={{ textAlign: 'center' }}>
      <Logo size="large" />
      <p style={{ marginTop: 16, color: '#666' }}>
        ✓ Logged in successfully
      </p>
      <p style={{ fontSize: 14, color: '#999' }}>
        (Calendar app would load here)
      </p>
      <button 
        onClick={() => navigate('home')}
        style={{ 
          ...styles.button,
          width: 'auto',
          marginTop: 24,
          padding: '10px 20px',
          backgroundColor: '#666'
        }}
      >
        Log out
      </button>
    </div>
  </div>
);

// Main App with Router
export default function BillWatchAuth() {
  const { page, navigate } = useSimpleRouter();
  const [modal, setModal] = useState(null);

  // Handle navigation from modals
  const handleNavigate = (target) => {
    if (target === 'login' || target === 'signup' || target === 'forgot') {
      setModal(target);
    } else {
      setModal(null);
      navigate(target);
    }
  };

  if (page === 'app') {
    return <AppPage navigate={handleNavigate} />;
  }

  return <HomePage navigate={handleNavigate} modal={modal} setModal={setModal} />;
}
