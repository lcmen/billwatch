import React, { useState, useMemo, useEffect } from 'react';

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
    else if (cycle === 'quarterly') current.setMonth(current.getMonth() - 3);
    else current.setFullYear(current.getFullYear() - 1);
  }
  while (current.getFullYear() < year) {
    if (cycle === 'monthly') current.setMonth(current.getMonth() + 1);
    else if (cycle === 'quarterly') current.setMonth(current.getMonth() + 3);
    else current.setFullYear(current.getFullYear() + 1);
  }
  while (current.getFullYear() === year) {
    dates.push(new Date(current));
    if (cycle === 'monthly') current.setMonth(current.getMonth() + 1);
    else if (cycle === 'quarterly') current.setMonth(current.getMonth() + 3);
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
];

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const DAYS_SHORT = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
const formatDateKey = (date) => `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
const getMonthlyEquivalent = (price, cycle) => {
  if (cycle === 'yearly') return price / 12;
  if (cycle === 'quarterly') return price / 3;
  return price;
};

export default function BillWatch() {
  const [bills, setBills] = useState(initialBills);
  const [year, setYear] = useState(2026);
  const [selectedDate, setSelectedDate] = useState(null);
  const [selectedCategories, setSelectedCategories] = useState([]);
  const [showAddModal, setShowAddModal] = useState(false);
  const [showMenu, setShowMenu] = useState(false);
  const [newBill, setNewBill] = useState({ name: '', price: '', cycle: 'monthly', startDate: '', category: 'Other' });
  const [detectedService, setDetectedService] = useState(null);
  
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

  const totalMonthly = bills.reduce((sum, bill) => sum + getMonthlyEquivalent(bill.price, bill.cycle), 0);
  
  const activeCategories = useMemo(() => {
    const cats = new Set(bills.map(b => b.category));
    return Object.keys(CATEGORIES).filter(c => cats.has(c));
  }, [bills]);

  const toggleCategory = (cat) => {
    setSelectedCategories(prev => 
      prev.includes(cat) 
        ? prev.filter(c => c !== cat)
        : [...prev, cat]
    );
  };

  const handleInputChange = (value) => {
    setNewBill({ ...newBill, name: value });
    const key = extractDomain(value);
    const matchedKey = Object.keys(logoDatabase).find(k => key.includes(k) || k.includes(key));
    
    if (matchedKey) {
      const service = logoDatabase[matchedKey];
      setDetectedService(service);
      setNewBill(prev => ({ ...prev, name: service.name, price: prev.price || service.defaultPrice, category: service.category }));
    } else {
      setDetectedService(null);
    }
  };

  const handleAddBill = () => {
    if (!newBill.name || !newBill.startDate) return;
    setBills([...bills, {
      id: Date.now(),
      name: newBill.name,
      logo: detectedService?.logo || null,
      category: newBill.category,
      price: parseFloat(newBill.price) || 0,
      cycle: newBill.cycle,
      startDate: newBill.startDate,
    }]);
    setShowAddModal(false);
    setNewBill({ name: '', price: '', cycle: 'monthly', startDate: '', category: 'Other' });
    setDetectedService(null);
  };

  const renderBillLabel = (billsList) => {
    if (billsList.length === 0) return null;
    
    if (billsList.length === 1) {
      const bill = billsList[0];
      return (
        <div style={{
          fontSize: 9,
          fontWeight: 500,
          color: 'white',
          backgroundColor: CATEGORIES[bill.category]?.color || '#6b7280',
          padding: '2px 4px',
          borderRadius: 3,
          whiteSpace: 'nowrap',
          overflow: 'hidden',
          textOverflow: 'ellipsis',
        }}>
          {bill.name}
        </div>
      );
    }
    
    return (
      <div style={{
        fontSize: 9,
        fontWeight: 500,
        color: 'white',
        backgroundColor: '#6b7280',
        padding: '2px 4px',
        borderRadius: 3,
        whiteSpace: 'nowrap',
      }}>
        {billsList.length} bills
      </div>
    );
  };

  return (
    <div style={{
      minHeight: '100vh',
      backgroundColor: '#ffffff',
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
      color: '#1a1a1a'
    }}>
      {/* Header */}
      <header style={{
        position: 'sticky',
        top: 0,
        zIndex: 20,
        backgroundColor: 'white',
        borderBottom: '1px solid #e5e5e5'
      }}>
        <div style={{ maxWidth: 1400, margin: '0 auto', padding: '12px 16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
              <button 
                onClick={() => setShowMenu(!showMenu)}
                style={{ 
                  padding: 8, 
                  background: showMenu ? '#f5f5f5' : 'none', 
                  border: 'none', 
                  borderRadius: 8,
                  cursor: 'pointer',
                  position: 'relative'
                }}
              >
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#666" strokeWidth="2">
                  <path d="M3 12h18M3 6h18M3 18h18" />
                </svg>
                {selectedCategories.length > 0 && (
                  <span style={{
                    position: 'absolute',
                    top: 4,
                    right: 4,
                    width: 8,
                    height: 8,
                    backgroundColor: '#f97316',
                    borderRadius: '50%'
                  }} />
                )}
              </button>
              
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <button onClick={() => setYear(y => y - 1)} style={{ padding: 8, background: 'none', border: 'none', cursor: 'pointer', color: '#666', fontSize: 16 }}>‹</button>
                <span style={{ fontSize: 18, fontWeight: 600, minWidth: 60, textAlign: 'center' }}>{year}</span>
                <button onClick={() => setYear(y => y + 1)} style={{ padding: 8, background: 'none', border: 'none', cursor: 'pointer', color: '#666', fontSize: 16 }}>›</button>
              </div>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
              <div style={{ fontSize: 14, color: '#666' }}>
                <strong style={{ color: '#1a1a1a' }}>${totalMonthly.toFixed(0)}</strong>/mo
              </div>
              
              <button 
                onClick={() => setShowAddModal(true)}
                style={{
                  display: 'flex', alignItems: 'center', gap: 6,
                  padding: '8px 16px', backgroundColor: '#f97316', color: 'white',
                  border: 'none', borderRadius: 8, fontSize: 14, fontWeight: 500, cursor: 'pointer'
                }}
              >
                + Create bill
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Slide-out Menu */}
      {showMenu && (
        <>
          <div 
            onClick={() => setShowMenu(false)}
            style={{
              position: 'fixed',
              inset: 0,
              backgroundColor: 'rgba(0,0,0,0.3)',
              zIndex: 25
            }}
          />
          <div style={{
            position: 'fixed',
            top: 0,
            left: 0,
            bottom: 0,
            width: 280,
            backgroundColor: 'white',
            zIndex: 30,
            boxShadow: '4px 0 20px rgba(0,0,0,0.15)',
            display: 'flex',
            flexDirection: 'column'
          }}>
            <div style={{ padding: 20, borderBottom: '1px solid #eee' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <h2 style={{ fontSize: 18, fontWeight: 700, margin: 0 }}>BillWatch</h2>
                <button 
                  onClick={() => setShowMenu(false)}
                  style={{ padding: 8, background: '#f5f5f5', border: 'none', borderRadius: 8, cursor: 'pointer' }}
                >
                  ✕
                </button>
              </div>
            </div>
            
            <div style={{ padding: 20, flex: 1, overflowY: 'auto' }}>
              {/* Categories header with X clear button */}
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
                <h3 style={{ fontSize: 12, fontWeight: 600, color: '#888', textTransform: 'uppercase', letterSpacing: 0.5, margin: 0 }}>
                  Categories
                </h3>
                {selectedCategories.length > 0 && (
                  <button
                    onClick={() => setSelectedCategories([])}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      width: 20,
                      height: 20,
                      padding: 0,
                      backgroundColor: '#f5f5f5',
                      border: 'none',
                      borderRadius: 4,
                      cursor: 'pointer',
                      color: '#999',
                      fontSize: 12
                    }}
                    title="Clear filters"
                  >
                    ✕
                  </button>
                )}
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                {activeCategories.map(cat => {
                  const isSelected = selectedCategories.includes(cat);
                  const count = bills.filter(b => b.category === cat).length;
                  return (
                    <button
                      key={cat}
                      onClick={() => toggleCategory(cat)}
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: 12,
                        padding: '10px 12px',
                        backgroundColor: isSelected ? CATEGORIES[cat].color : '#f8f8f8',
                        color: isSelected ? 'white' : '#333',
                        border: 'none',
                        borderRadius: 8,
                        cursor: 'pointer',
                        textAlign: 'left',
                        transition: 'all 0.15s'
                      }}
                    >
                      <span style={{
                        width: 10,
                        height: 10,
                        borderRadius: '50%',
                        backgroundColor: isSelected ? 'white' : CATEGORIES[cat].color,
                        flexShrink: 0
                      }} />
                      <span style={{ flex: 1, fontSize: 14, fontWeight: 500 }}>
                        {cat}
                      </span>
                      <span style={{ fontSize: 12, fontWeight: 500, color: isSelected ? 'rgba(255,255,255,0.8)' : '#999' }}>
                        {count}
                      </span>
                    </button>
                  );
                })}
              </div>
              
              <div style={{ height: 1, backgroundColor: '#eee', margin: '20px 0' }} />
              
              <h3 style={{ fontSize: 12, fontWeight: 600, color: '#888', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 12, margin: '0 0 12px 0' }}>
                Account
              </h3>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                <button style={{
                  display: 'flex', alignItems: 'center', gap: 12, padding: '10px 12px',
                  backgroundColor: '#f8f8f8', color: '#333', border: 'none', borderRadius: 8,
                  cursor: 'pointer', textAlign: 'left', fontSize: 14, fontWeight: 500
                }}>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/>
                  </svg>
                  Settings
                </button>
                <button style={{
                  display: 'flex', alignItems: 'center', gap: 12, padding: '10px 12px',
                  backgroundColor: '#f8f8f8', color: '#333', border: 'none', borderRadius: 8,
                  cursor: 'pointer', textAlign: 'left', fontSize: 14, fontWeight: 500
                }}>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/>
                  </svg>
                  Help & Support
                </button>
                <button style={{
                  display: 'flex', alignItems: 'center', gap: 12, padding: '10px 12px',
                  backgroundColor: '#fef2f2', color: '#dc2626', border: 'none', borderRadius: 8,
                  cursor: 'pointer', textAlign: 'left', fontSize: 14, fontWeight: 500
                }}>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>
                  </svg>
                  Log out
                </button>
              </div>
            </div>
            
            <div style={{ padding: 16, borderTop: '1px solid #eee', backgroundColor: '#fafafa' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 13, color: '#666', marginBottom: 4 }}>
                <span>Monthly</span>
                <strong style={{ color: '#333' }}>${totalMonthly.toFixed(2)}</strong>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 13, color: '#666' }}>
                <span>Yearly</span>
                <strong style={{ color: '#333' }}>${(totalMonthly * 12).toFixed(2)}</strong>
              </div>
            </div>
          </div>
        </>
      )}

      {/* Calendar Grid */}
      <div style={{ padding: '12px', maxWidth: 1400, margin: '0 auto' }}>
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fill, minmax(70px, 1fr))',
          backgroundColor: '#f0f0f0',
          border: '1px solid #ddd',
          borderRadius: 8,
          overflow: 'hidden',
        }}>
          {allDays.map(day => {
            const dayBills = renewalMap[day.dateKey] || [];
            const hasBills = dayBills.length > 0;
            
            let bgColor = 'white';
            if (day.isToday) {
              bgColor = '#fff7ed';
            } else if (day.isFirstOfMonth) {
              bgColor = '#fef9e7';
            } else if (day.isWeekend) {
              bgColor = '#fafafa';
            }
            
            return (
              <div
                key={day.dateKey}
                onClick={() => hasBills && setSelectedDate({ ...day, bills: dayBills })}
                style={{
                  height: 68,
                  display: 'flex',
                  flexDirection: 'column',
                  padding: 4,
                  backgroundColor: bgColor,
                  cursor: hasBills ? 'pointer' : 'default',
                  position: 'relative',
                  borderRight: '1px solid #eee',
                  borderBottom: '1px solid #eee',
                  boxSizing: 'border-box',
                  outline: day.isToday ? '2px solid #f97316' : 'none',
                  outlineOffset: '-2px',
                  zIndex: day.isToday ? 1 : 0,
                }}
              >
                <div style={{ display: 'flex', alignItems: 'baseline', gap: 2, marginBottom: 2 }}>
                  {day.isFirstOfMonth && (
                    <span style={{ fontSize: 10, fontWeight: 700, color: '#f97316' }}>
                      {MONTHS[day.month].toUpperCase()}
                    </span>
                  )}
                  <span style={{ fontSize: 10, fontWeight: 600, color: day.isWeekend ? '#999' : '#666' }}>
                    {DAYS_SHORT[day.dayOfWeek]}
                  </span>
                  <span style={{ fontSize: 12, fontWeight: day.isToday ? 700 : 600, color: day.isToday ? '#f97316' : day.isWeekend ? '#999' : '#333' }}>
                    {day.day}
                  </span>
                </div>
                
                <div style={{ display: 'flex', flexDirection: 'column', gap: 2, flex: 1, overflow: 'hidden' }}>
                  {dayBills.length === 1 && renderBillLabel(dayBills)}
                  {dayBills.length === 2 && (
                    <>
                      {renderBillLabel([dayBills[0]])}
                      {renderBillLabel([dayBills[1]])}
                    </>
                  )}
                  {dayBills.length > 2 && (
                    <>
                      {renderBillLabel([dayBills[0]])}
                      <div style={{
                        fontSize: 9, fontWeight: 500, color: 'white',
                        backgroundColor: '#6b7280', padding: '2px 4px', borderRadius: 3,
                      }}>
                        +{dayBills.length - 1} more
                      </div>
                    </>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Date Details Modal */}
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
            padding: 24,
            width: '100%',
            maxWidth: 420,
            boxShadow: '0 25px 50px rgba(0,0,0,0.25)'
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start', marginBottom: 20 }}>
              <div>
                <p style={{ fontSize: 13, color: '#888', marginBottom: 4, margin: 0 }}>{selectedDate.date.toLocaleDateString('en-US', { weekday: 'long' })}</p>
                <h3 style={{ fontSize: 24, fontWeight: 700, margin: 0 }}>{selectedDate.date.toLocaleDateString('en-US', { month: 'long', day: 'numeric' })}</h3>
              </div>
              <button onClick={() => setSelectedDate(null)} style={{ padding: 8, background: '#f5f5f5', border: 'none', borderRadius: 8, cursor: 'pointer', fontSize: 16 }}>✕</button>
            </div>
            
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {selectedDate.bills.map(bill => (
                <div key={bill.id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: 14, backgroundColor: '#f8f8f8', borderRadius: 12 }}>
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
                    <option value="quarterly">Quarterly</option>
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
