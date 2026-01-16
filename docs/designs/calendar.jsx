import React, { useState, useMemo, useRef, useEffect } from 'react';

const CATEGORIES = {
  'Housing': { color: '#ef4444' },
  'Utilities': { color: '#f59e0b' },
  'Insurance': { color: '#8b5cf6' },
  'Subscriptions': { color: '#10b981' },
  'Finance': { color: '#3b82f6' },
  'Other': { color: '#6b7280' },
};

const logoDatabase = {
  'spotify': { name: 'Spotify', logo: 'https://logo.clearbit.com/spotify.com', category: 'Subscriptions', defaultPrice: 10.99 },
  'youtube': { name: 'YouTube', logo: 'https://logo.clearbit.com/youtube.com', category: 'Subscriptions', defaultPrice: 13.99 },
  'netflix': { name: 'Netflix', logo: 'https://logo.clearbit.com/netflix.com', category: 'Subscriptions', defaultPrice: 15.49 },
  'disney': { name: 'Disney+', logo: 'https://logo.clearbit.com/disneyplus.com', category: 'Subscriptions', defaultPrice: 13.99 },
  'hulu': { name: 'Hulu', logo: 'https://logo.clearbit.com/hulu.com', category: 'Subscriptions', defaultPrice: 17.99 },
  'amazon': { name: 'Prime', logo: 'https://logo.clearbit.com/amazon.com', category: 'Subscriptions', defaultPrice: 14.99 },
  'icloud': { name: 'iCloud+', logo: 'https://logo.clearbit.com/icloud.com', category: 'Subscriptions', defaultPrice: 2.99 },
  'chatgpt': { name: 'ChatGPT', logo: 'https://logo.clearbit.com/openai.com', category: 'Subscriptions', defaultPrice: 20.00 },
  'claude': { name: 'Claude Pro', logo: 'https://logo.clearbit.com/anthropic.com', category: 'Subscriptions', defaultPrice: 20.00 },
  'github': { name: 'GitHub', logo: 'https://logo.clearbit.com/github.com', category: 'Subscriptions', defaultPrice: 4.00 },
  'pge': { name: 'PG&E', logo: 'https://logo.clearbit.com/pge.com', category: 'Utilities', defaultPrice: 150.00 },
  'comcast': { name: 'Xfinity', logo: 'https://logo.clearbit.com/xfinity.com', category: 'Utilities', defaultPrice: 89.99 },
  'verizon': { name: 'Verizon', logo: 'https://logo.clearbit.com/verizon.com', category: 'Utilities', defaultPrice: 85.00 },
  'att': { name: 'AT&T', logo: 'https://logo.clearbit.com/att.com', category: 'Utilities', defaultPrice: 75.00 },
  'tmobile': { name: 'T-Mobile', logo: 'https://logo.clearbit.com/t-mobile.com', category: 'Utilities', defaultPrice: 70.00 },
};

const extractDomain = (input) => {
  try {
    if (input.includes('.')) {
      const url = input.startsWith('http') ? input : `https://${input}`;
      return new URL(url).hostname.replace('www.', '').split('.')[0].toLowerCase();
    }
    return input.toLowerCase().replace(/[^a-z0-9]/g, '');
  } catch {
    return input.toLowerCase().replace(/[^a-z0-9]/g, '');
  }
};

const generateRenewalDates = (startDate, cycle, year) => {
  const dates = [];
  let current = new Date(startDate);
  while (current.getFullYear() > year) {
    if (cycle === 'monthly') current.setMonth(current.getMonth() - 1);
    else current.setFullYear(current.getFullYear() - 1);
  }
  while (current.getFullYear() < year) {
    if (cycle === 'monthly') current.setMonth(current.getMonth() + 1);
    else current.setFullYear(current.getFullYear() + 1);
  }
  while (current.getFullYear() === year) {
    dates.push(new Date(current));
    if (cycle === 'monthly') current.setMonth(current.getMonth() + 1);
    else current.setFullYear(current.getFullYear() + 1);
  }
  return dates;
};

const initialBills = [
  { id: 1, name: 'Rent', logo: null, category: 'Housing', price: 2500.00, cycle: 'monthly', startDate: '2026-01-01' },
  { id: 2, name: 'Electric', logo: null, category: 'Utilities', price: 120.00, cycle: 'monthly', startDate: '2026-01-15' },
  { id: 3, name: 'Gas', logo: null, category: 'Utilities', price: 45.00, cycle: 'monthly', startDate: '2026-01-15' },
  { id: 4, name: 'Internet', logo: 'https://logo.clearbit.com/xfinity.com', category: 'Utilities', price: 79.99, cycle: 'monthly', startDate: '2026-01-20' },
  { id: 5, name: 'Phone', logo: 'https://logo.clearbit.com/verizon.com', category: 'Utilities', price: 85.00, cycle: 'monthly', startDate: '2026-01-22' },
  { id: 6, name: 'Car Insurance', logo: null, category: 'Insurance', price: 180.00, cycle: 'monthly', startDate: '2026-01-05' },
  { id: 7, name: 'Health Insurance', logo: null, category: 'Insurance', price: 450.00, cycle: 'monthly', startDate: '2026-01-01' },
  { id: 8, name: 'Netflix', logo: 'https://logo.clearbit.com/netflix.com', category: 'Subscriptions', price: 15.49, cycle: 'monthly', startDate: '2026-01-10' },
  { id: 9, name: 'Spotify', logo: 'https://logo.clearbit.com/spotify.com', category: 'Subscriptions', price: 10.99, cycle: 'monthly', startDate: '2026-01-15' },
  { id: 10, name: 'iCloud+', logo: 'https://logo.clearbit.com/icloud.com', category: 'Subscriptions', price: 2.99, cycle: 'monthly', startDate: '2026-01-28' },
  { id: 11, name: 'Credit Card', logo: null, category: 'Finance', price: 0, cycle: 'monthly', startDate: '2026-01-25' },
  { id: 12, name: 'Amazon Prime', logo: 'https://logo.clearbit.com/amazon.com', category: 'Subscriptions', price: 139.00, cycle: 'yearly', startDate: '2026-03-15' },
];

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const DAYS_SHORT = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
const formatDateKey = (date) => `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
const getMonthlyEquivalent = (price, cycle) => cycle === 'yearly' ? price / 12 : price;

// Dropdown hook for click outside
const useDropdown = () => {
  const [isOpen, setIsOpen] = useState(false);
  const ref = useRef(null);
  
  useEffect(() => {
    const handleClick = (e) => {
      if (ref.current && !ref.current.contains(e.target)) setIsOpen(false);
    };
    document.addEventListener('mousedown', handleClick);
    return () => document.removeEventListener('mousedown', handleClick);
  }, []);
  
  return { isOpen, setIsOpen, ref };
};

export default function BillWatch() {
  const [bills, setBills] = useState(initialBills);
  const [year, setYear] = useState(2026);
  const [selectedDate, setSelectedDate] = useState(null);
  const [selectedCategories, setSelectedCategories] = useState([]);
  const [showAddModal, setShowAddModal] = useState(false);
  const [newBill, setNewBill] = useState({ name: '', price: '', cycle: 'monthly', startDate: '', category: 'Other' });
  const [detectedService, setDetectedService] = useState(null);
  
  const categoryDropdown = useDropdown();
  const settingsDropdown = useDropdown();
  
  const today = new Date('2026-01-09');
  const todayKey = formatDateKey(today);

  const allDays = useMemo(() => {
    const days = [];
    for (let month = 0; month < 12; month++) {
      const daysInMonth = new Date(year, month + 1, 0).getDate();
      for (let day = 1; day <= daysInMonth; day++) {
        const date = new Date(year, month, day);
        days.push({
          date,
          dateKey: formatDateKey(date),
          day,
          month,
          dayOfWeek: date.getDay(),
          isWeekend: date.getDay() === 0 || date.getDay() === 6,
          isToday: formatDateKey(date) === todayKey,
          isFirstOfMonth: day === 1,
        });
      }
    }
    return days;
  }, [year, todayKey]);

  const renewalMap = useMemo(() => {
    const map = {};
    const filteredBills = selectedCategories.length > 0
      ? bills.filter(b => selectedCategories.includes(b.category))
      : bills;
    
    filteredBills.forEach(bill => {
      generateRenewalDates(bill.startDate, bill.cycle, year).forEach(date => {
        const key = formatDateKey(date);
        if (!map[key]) map[key] = [];
        map[key].push(bill);
      });
    });
    return map;
  }, [bills, year, selectedCategories]);

  const { totalMonthly, totalYearly } = useMemo(() => {
    const monthly = bills.reduce((sum, bill) => sum + getMonthlyEquivalent(bill.price, bill.cycle), 0);
    return { totalMonthly: monthly, totalYearly: monthly * 12 };
  }, [bills]);
  
  const categoryStats = useMemo(() => {
    const stats = {};
    Object.keys(CATEGORIES).forEach(cat => {
      stats[cat] = bills.filter(b => b.category === cat).length;
    });
    return stats;
  }, [bills]);

  const toggleCategory = (cat) => {
    setSelectedCategories(prev => 
      prev.includes(cat) ? prev.filter(c => c !== cat) : [...prev, cat]
    );
  };

  const handleInputChange = (value) => {
    setNewBill({ ...newBill, name: value });
    const key = extractDomain(value);
    const matchedKey = Object.keys(logoDatabase).find(k => key.includes(k) || k.includes(key));
    
    if (matchedKey) {
      const service = logoDatabase[matchedKey];
      setDetectedService(service);
      setNewBill(prev => ({
        ...prev,
        name: service.name,
        category: service.category,
        price: service.defaultPrice.toString()
      }));
    } else {
      setDetectedService(null);
    }
  };

  const handleAddBill = () => {
    if (!newBill.name || !newBill.startDate) return;
    const bill = {
      id: Date.now(),
      name: newBill.name,
      logo: detectedService?.logo || null,
      category: newBill.category,
      price: parseFloat(newBill.price) || 0,
      cycle: newBill.cycle,
      startDate: newBill.startDate,
    };
    setBills([...bills, bill]);
    setNewBill({ name: '', price: '', cycle: 'monthly', startDate: '', category: 'Other' });
    setDetectedService(null);
    setShowAddModal(false);
  };

  const formatFullDate = (dateKey) => {
    const date = new Date(dateKey + 'T00:00:00');
    return date.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' });
  };

  const getCellBg = (d) => {
    if (d.isToday) return '#fff7ed';
    if (d.isFirstOfMonth) return '#fef9e7';
    if (d.isWeekend) return '#fafafa';
    return 'white';
  };

  return (
    <div style={{ minHeight: '100vh', backgroundColor: 'white' }}>
      {/* Navbar */}
      <header style={{
        position: 'sticky', top: 0, zIndex: 20,
        backgroundColor: 'white',
        borderBottom: '1px solid #e5e5e5',
        padding: '12px 16px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
          {/* Logo */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{
              width: 32, height: 32, borderRadius: 8,
              backgroundColor: '#f97316',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: 'white', fontWeight: 800, fontSize: 16
            }}>B</div>
            <span style={{ fontWeight: 700, fontSize: 18, color: '#1a1a1a' }}>BillWatch</span>
          </div>
          
          {/* Year Navigation */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginLeft: 8 }}>
            <button 
              onClick={() => setYear(year - 1)}
              style={{ padding: '6px 10px', background: 'none', border: 'none', cursor: 'pointer', fontSize: 18, color: '#666' }}
            >‹</button>
            <span style={{ fontSize: 18, fontWeight: 600, width: 50, textAlign: 'center' }}>{year}</span>
            <button 
              onClick={() => setYear(year + 1)}
              style={{ padding: '6px 10px', background: 'none', border: 'none', cursor: 'pointer', fontSize: 18, color: '#666' }}
            >›</button>
          </div>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          {/* Add Bill Button */}
          <button
            onClick={() => setShowAddModal(true)}
            style={{
              padding: '8px 16px',
              backgroundColor: '#f97316', color: 'white',
              border: 'none', borderRadius: 8,
              fontSize: 14, fontWeight: 600, cursor: 'pointer',
              display: 'flex', alignItems: 'center', gap: 6
            }}
          >
            <span style={{ fontSize: 16 }}>+</span> Add bill
          </button>
          
          {/* Settings Dropdown */}
          <div ref={settingsDropdown.ref} style={{ position: 'relative' }}>
            <button
              onClick={() => settingsDropdown.setIsOpen(!settingsDropdown.isOpen)}
              style={{
                padding: 8, background: 'none', border: '1px solid #e5e5e5',
                borderRadius: 8, cursor: 'pointer', display: 'flex', alignItems: 'center'
              }}
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#666" strokeWidth="2">
                <circle cx="12" cy="12" r="3"/>
                <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/>
              </svg>
            </button>
            
            {settingsDropdown.isOpen && (
              <div style={{
                position: 'absolute', top: '100%', right: 0, marginTop: 4,
                backgroundColor: 'white', borderRadius: 10,
                boxShadow: '0 10px 40px rgba(0,0,0,0.15)',
                border: '1px solid #e5e5e5',
                minWidth: 180, overflow: 'hidden', zIndex: 30
              }}>
                <button style={{
                  width: '100%', padding: '12px 16px', border: 'none', background: 'none',
                  textAlign: 'left', cursor: 'pointer', fontSize: 14, color: '#333',
                  display: 'flex', alignItems: 'center', gap: 10
                }}>
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <circle cx="12" cy="12" r="3"/>
                    <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/>
                  </svg>
                  Settings
                </button>
                <button style={{
                  width: '100%', padding: '12px 16px', border: 'none', background: 'none',
                  textAlign: 'left', cursor: 'pointer', fontSize: 14, color: '#333',
                  display: 'flex', alignItems: 'center', gap: 10
                }}>
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <circle cx="12" cy="12" r="10"/>
                    <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/>
                    <line x1="12" y1="17" x2="12.01" y2="17"/>
                  </svg>
                  Help & Support
                </button>
                <div style={{ height: 1, backgroundColor: '#e5e5e5', margin: '4px 0' }} />
                <button style={{
                  width: '100%', padding: '12px 16px', border: 'none', background: 'none',
                  textAlign: 'left', cursor: 'pointer', fontSize: 14, color: '#ef4444',
                  display: 'flex', alignItems: 'center', gap: 10
                }}>
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                    <polyline points="16 17 21 12 16 7"/>
                    <line x1="21" y1="12" x2="9" y2="12"/>
                  </svg>
                  Log out
                </button>
              </div>
            )}
          </div>
        </div>
      </header>

      {/* Filter Bar */}
      <div style={{
        padding: '10px 16px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between'
      }}>
        {/* Categories Dropdown */}
        <div ref={categoryDropdown.ref} style={{ position: 'relative' }}>
          <button
            onClick={() => categoryDropdown.setIsOpen(!categoryDropdown.isOpen)}
            style={{
              padding: '8px 12px',
              backgroundColor: selectedCategories.length > 0 ? '#fff7ed' : 'white',
              border: selectedCategories.length > 0 ? '1px solid #fed7aa' : '1px solid #e5e5e5',
              borderRadius: 8, cursor: 'pointer',
              display: 'flex', alignItems: 'center', gap: 8,
              fontSize: 14, color: '#333'
            }}
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/>
            </svg>
            {selectedCategories.length > 0 ? (
              <>
                <span>Filtered</span>
                <span style={{
                  backgroundColor: '#f97316', color: 'white',
                  padding: '2px 6px', borderRadius: 10, fontSize: 11, fontWeight: 600
                }}>{selectedCategories.length}</span>
              </>
            ) : (
              <span>All Categories</span>
            )}
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" style={{ marginLeft: 2 }}>
              <polyline points="6 9 12 15 18 9"/>
            </svg>
          </button>
          
          {categoryDropdown.isOpen && (
            <div style={{
              position: 'absolute', top: '100%', left: 0, marginTop: 4,
              backgroundColor: 'white', borderRadius: 10,
              boxShadow: '0 10px 40px rgba(0,0,0,0.15)',
              border: '1px solid #e5e5e5',
              minWidth: 220, overflow: 'hidden', zIndex: 30, padding: 8
            }}>
              <div style={{
                display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                padding: '4px 8px', marginBottom: 4
              }}>
                <span style={{ fontSize: 12, fontWeight: 600, color: '#888', textTransform: 'uppercase' }}>Categories</span>
                {selectedCategories.length > 0 && (
                  <button
                    onClick={() => setSelectedCategories([])}
                    style={{
                      padding: 4, backgroundColor: '#fee2e2', color: '#ef4444',
                      border: 'none', borderRadius: 4, cursor: 'pointer',
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      width: 20, height: 20
                    }}
                  >
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                      <line x1="18" y1="6" x2="6" y2="18"/>
                      <line x1="6" y1="6" x2="18" y2="18"/>
                    </svg>
                  </button>
                )}
              </div>
              {Object.entries(CATEGORIES).map(([cat, { color }]) => {
                const isSelected = selectedCategories.includes(cat);
                const count = categoryStats[cat] || 0;
                return (
                  <button
                    key={cat}
                    onClick={() => toggleCategory(cat)}
                    style={{
                      width: '100%', padding: '10px 12px',
                      backgroundColor: isSelected ? `${color}15` : 'transparent',
                      border: 'none', borderRadius: 6,
                      textAlign: 'left', cursor: 'pointer',
                      display: 'flex', alignItems: 'center', gap: 10,
                      marginBottom: 2
                    }}
                  >
                    <span style={{
                      width: 12, height: 12, borderRadius: 3,
                      backgroundColor: isSelected ? color : 'transparent',
                      border: `2px solid ${color}`
                    }} />
                    <span style={{ flex: 1, fontSize: 14, color: '#333' }}>{cat}</span>
                    <span style={{
                      fontSize: 12, color: '#888',
                      backgroundColor: '#f5f5f5', padding: '2px 8px', borderRadius: 10
                    }}>{count}</span>
                  </button>
                );
              })}
            </div>
          )}
        </div>

        {/* Totals */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 16, fontSize: 14 }}>
          <span style={{ color: '#888' }}>Monthly <strong style={{ color: '#333' }}>${totalMonthly.toFixed(0)}</strong></span>
          <span style={{ color: '#ccc' }}>·</span>
          <span style={{ color: '#888' }}>Yearly <strong style={{ color: '#333' }}>${totalYearly.toFixed(0)}</strong></span>
        </div>
      </div>

      {/* Calendar Grid */}
      <div style={{ padding: 8 }}>
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fill, minmax(70px, 1fr))',
          border: '1px solid #e5e5e5',
          borderRadius: 10,
          overflow: 'hidden',
          backgroundColor: '#e5e5e5',
          gap: 1
        }}>
          {allDays.map((d) => {
            const dayBills = renewalMap[d.dateKey] || [];
            const hasBills = dayBills.length > 0;
            
            return (
              <div
                key={d.dateKey}
                onClick={() => hasBills && setSelectedDate({ dateKey: d.dateKey, bills: dayBills })}
                style={{
                  height: 64,
                  padding: 4,
                  backgroundColor: getCellBg(d),
                  display: 'flex', flexDirection: 'column',
                  cursor: hasBills ? 'pointer' : 'default',
                  position: 'relative',
                  boxShadow: d.isToday ? 'inset 0 0 0 2px #f97316' : 'none'
                }}
              >
                <div style={{ display: 'flex', alignItems: 'baseline', gap: 3, marginBottom: 2 }}>
                  {d.isFirstOfMonth && (
                    <span style={{ fontSize: 9, fontWeight: 700, color: '#f97316' }}>
                      {MONTHS[d.month].toUpperCase()}
                    </span>
                  )}
                  <span style={{
                    fontSize: 9, fontWeight: 600,
                    color: d.isWeekend ? '#bbb' : '#888'
                  }}>{DAYS_SHORT[d.dayOfWeek].slice(0, 3)}</span>
                  <span style={{
                    fontSize: 11, fontWeight: 600,
                    color: d.isToday ? '#f97316' : d.isWeekend ? '#bbb' : '#333'
                  }}>{d.day}</span>
                </div>
                
                <div style={{ display: 'flex', flexDirection: 'column', gap: 2, overflow: 'hidden', flex: 1 }}>
                  {dayBills.length === 1 ? (
                    <span style={{
                      fontSize: 9, fontWeight: 500,
                      color: 'white',
                      backgroundColor: CATEGORIES[dayBills[0].category]?.color || '#6b7280',
                      padding: '2px 4px',
                      borderRadius: 3,
                      whiteSpace: 'nowrap',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis'
                    }}>{dayBills[0].name}</span>
                  ) : dayBills.length === 2 ? (
                    <>
                      {dayBills.map((bill, i) => (
                        <span key={i} style={{
                          fontSize: 9, fontWeight: 500,
                          color: 'white',
                          backgroundColor: CATEGORIES[bill.category]?.color || '#6b7280',
                          padding: '2px 4px',
                          borderRadius: 3,
                          whiteSpace: 'nowrap',
                          overflow: 'hidden',
                          textOverflow: 'ellipsis'
                        }}>{bill.name}</span>
                      ))}
                    </>
                  ) : dayBills.length > 2 ? (
                    <>
                      <span style={{
                        fontSize: 9, fontWeight: 500,
                        color: 'white',
                        backgroundColor: CATEGORIES[dayBills[0].category]?.color || '#6b7280',
                        padding: '2px 4px',
                        borderRadius: 3,
                        whiteSpace: 'nowrap',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis'
                      }}>{dayBills[0].name}</span>
                      <span style={{
                        fontSize: 9, fontWeight: 600,
                        color: 'white', backgroundColor: '#6b7280',
                        padding: '2px 4px', borderRadius: 3
                      }}>+{dayBills.length - 1} more</span>
                    </>
                  ) : null}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Day Detail Modal */}
      {selectedDate && (
        <div 
          onClick={() => setSelectedDate(null)}
          style={{
            position: 'fixed', inset: 0,
            backgroundColor: 'rgba(0,0,0,0.5)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            zIndex: 50, padding: 16
          }}
        >
          <div onClick={e => e.stopPropagation()} style={{
            backgroundColor: 'white',
            borderRadius: 16,
            padding: 20,
            width: '100%',
            maxWidth: 400,
            maxHeight: '80vh',
            overflow: 'auto',
            boxShadow: '0 25px 50px rgba(0,0,0,0.25)'
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
              <h3 style={{ margin: 0, fontSize: 18, fontWeight: 700 }}>{formatFullDate(selectedDate.dateKey)}</h3>
              <button 
                onClick={() => setSelectedDate(null)}
                style={{ padding: 8, background: '#f5f5f5', border: 'none', borderRadius: 8, cursor: 'pointer' }}
              >✕</button>
            </div>
            
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {selectedDate.bills.map((bill) => (
                <div key={bill.id} style={{
                  display: 'flex', alignItems: 'center', gap: 12,
                  padding: 12, backgroundColor: '#fafafa', borderRadius: 10
                }}>
                  <div style={{ 
                    width: 44, height: 44, borderRadius: 10, 
                    backgroundColor: CATEGORIES[bill.category]?.color || '#6b7280',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    color: 'white', fontWeight: 700, fontSize: 14
                  }}>
                    {bill.logo ? (
                      <img src={bill.logo} alt="" style={{ width: 28, height: 28, borderRadius: 6 }} />
                    ) : (
                      bill.name.charAt(0)
                    )}
                  </div>
                  <div style={{ flex: 1 }}>
                    <p style={{ fontWeight: 600, fontSize: 15, marginBottom: 2, margin: 0 }}>{bill.name}</p>
                    <p style={{ fontSize: 12, color: '#888', display: 'flex', alignItems: 'center', gap: 6, margin: 0 }}>
                      <span style={{ width: 6, height: 6, borderRadius: '50%', backgroundColor: CATEGORIES[bill.category]?.color }} />
                      {bill.category} · {bill.cycle}
                    </p>
                  </div>
                  {bill.price > 0 && (
                    <p style={{ fontWeight: 700, fontSize: 16, margin: 0 }}>${bill.price.toFixed(2)}</p>
                  )}
                  <button 
                    onClick={() => { setBills(bills.filter(b => b.id !== bill.id)); setSelectedDate(null); }}
                    style={{ padding: 8, background: 'none', border: 'none', cursor: 'pointer', color: '#ef4444', fontSize: 16 }}
                  >✕</button>
                </div>
              ))}
            </div>
            
            {selectedDate.bills.length > 1 && selectedDate.bills.some(b => b.price > 0) && (
              <div style={{ marginTop: 16, paddingTop: 14, borderTop: '1px solid #eee', display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: '#888' }}>Total</span>
                <span style={{ fontWeight: 700, fontSize: 18 }}>${selectedDate.bills.reduce((s, b) => s + b.price, 0).toFixed(2)}</span>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Add Modal */}
      {showAddModal && (
        <div 
          onClick={() => setShowAddModal(false)}
          style={{
            position: 'fixed', inset: 0,
            backgroundColor: 'rgba(0,0,0,0.5)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            zIndex: 50, padding: 16
          }}
        >
          <div onClick={e => e.stopPropagation()} style={{
            backgroundColor: 'white',
            borderRadius: 16,
            padding: 24,
            width: '100%',
            maxWidth: 420,
            boxShadow: '0 25px 50px rgba(0,0,0,0.25)'
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
              <h3 style={{ fontSize: 20, fontWeight: 700, margin: 0 }}>Add Bill</h3>
              <button onClick={() => setShowAddModal(false)} style={{ padding: 8, background: '#f5f5f5', border: 'none', borderRadius: 8, cursor: 'pointer', fontSize: 16 }}>✕</button>
            </div>
            
            <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
              <div>
                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6, color: '#555' }}>Bill name</label>
                <input
                  type="text"
                  value={newBill.name}
                  onChange={(e) => handleInputChange(e.target.value)}
                  placeholder="e.g., Rent, Electric, Netflix..."
                  style={{ width: '100%', padding: 12, border: '1px solid #ddd', borderRadius: 10, fontSize: 14, boxSizing: 'border-box' }}
                />
              </div>
              
              {detectedService && (
                <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: 10, backgroundColor: '#f0fdf4', borderRadius: 10, border: '1px solid #bbf7d0' }}>
                  <img src={detectedService.logo} alt="" style={{ width: 32, height: 32, borderRadius: 8 }} />
                  <div>
                    <p style={{ fontWeight: 600, fontSize: 13, margin: 0 }}>{detectedService.name}</p>
                    <p style={{ fontSize: 11, color: '#16a34a', margin: 0 }}>✓ Detected</p>
                  </div>
                </div>
              )}
              
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                <div>
                  <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6, color: '#555' }}>Amount</label>
                  <input
                    type="number"
                    step="0.01"
                    value={newBill.price}
                    onChange={(e) => setNewBill({ ...newBill, price: e.target.value })}
                    placeholder="0.00"
                    style={{ width: '100%', padding: 12, border: '1px solid #ddd', borderRadius: 10, fontSize: 14, boxSizing: 'border-box' }}
                  />
                </div>
                <div>
                  <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6, color: '#555' }}>Frequency</label>
                  <select
                    value={newBill.cycle}
                    onChange={(e) => setNewBill({ ...newBill, cycle: e.target.value })}
                    style={{ width: '100%', padding: 12, border: '1px solid #ddd', borderRadius: 10, fontSize: 14, boxSizing: 'border-box', backgroundColor: 'white' }}
                  >
                    <option value="monthly">Monthly</option>
                    <option value="yearly">Yearly</option>
                  </select>
                </div>
              </div>
              
              <div>
                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6, color: '#555' }}>Category</label>
                <select
                  value={newBill.category}
                  onChange={(e) => setNewBill({ ...newBill, category: e.target.value })}
                  style={{ width: '100%', padding: 12, border: '1px solid #ddd', borderRadius: 10, fontSize: 14, boxSizing: 'border-box', backgroundColor: 'white' }}
                >
                  {Object.keys(CATEGORIES).map(cat => (
                    <option key={cat} value={cat}>{cat}</option>
                  ))}
                </select>
              </div>
              
              <div>
                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6, color: '#555' }}>Due date</label>
                <input
                  type="date"
                  value={newBill.startDate}
                  onChange={(e) => setNewBill({ ...newBill, startDate: e.target.value })}
                  style={{ width: '100%', padding: 12, border: '1px solid #ddd', borderRadius: 10, fontSize: 14, boxSizing: 'border-box' }}
                />
              </div>
              
              <button
                onClick={handleAddBill}
                disabled={!newBill.name || !newBill.startDate}
                style={{
                  width: '100%', padding: 14, marginTop: 6,
                  backgroundColor: (!newBill.name || !newBill.startDate) ? '#e5e5e5' : '#f97316',
                  color: (!newBill.name || !newBill.startDate) ? '#aaa' : 'white',
                  border: 'none', borderRadius: 10,
                  fontSize: 15, fontWeight: 600,
                  cursor: (!newBill.name || !newBill.startDate) ? 'not-allowed' : 'pointer'
                }}
              >
                Add Bill
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
