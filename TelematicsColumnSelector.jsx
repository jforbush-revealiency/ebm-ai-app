import { useState, useCallback } from "react";

// ── Column definitions from CSV analysis ──────────────────────────────────────
const ALL_COLUMNS = [
  // ISO 8178 — required
  { csv: "percent_load",              db: "percent_load",              label: "Engine Load %",               category: "iso8178",     presence: 94,  required: true,  new: false, notes: "ISO 8178 threshold field" },
  { csv: "rpm",                       db: "rpm",                       label: "Engine RPM",                  category: "iso8178",     presence: 100, required: true,  new: false, notes: "ISO 8178 threshold field" },
  // Emissions
  { csv: "nox_ppm",                   db: "nox_ppm",                   label: "NOx (ppm)",                   category: "emissions",   presence: 100, required: true,  new: false, notes: "Primary EBM algorithm input" },
  { csv: "co2_percent",               db: "co2_percent",               label: "CO₂ %",                       category: "emissions",   presence: 88,  required: true,  new: false, notes: "Primary EBM algorithm input" },
  { csv: "o2_percent",                db: "o2_percent",                label: "O₂ %",                        category: "emissions",   presence: 100, required: true,  new: false, notes: "EBM CO₂+O₂ check" },
  { csv: "co",                        db: "co",                        label: "CO (ppm)",                    category: "emissions",   presence: 0,   required: false, new: false, notes: "Not captured via telematics hardware" },
  // Engine health
  { csv: "coolant_temperature",       db: "coolant_temperature",       label: "Coolant Temp (°F)",           category: "engine",      presence: 100, required: false, new: false, notes: "" },
  { csv: "right_exhaust_temperature", db: "right_exhaust_temperature", label: "Right Exhaust Temp (°F)",     category: "engine",      presence: 100, required: false, new: false, notes: "" },
  { csv: "left_exhaust_temperature",  db: "left_exhaust_temperature",  label: "Left Exhaust Temp (°F)",      category: "engine",      presence: 100, required: false, new: false, notes: "" },
  { csv: "oil_pressure_psi",          db: "oil_pressure_psi",          label: "Oil Pressure (PSI)",          category: "engine",      presence: 100, required: false, new: false, notes: "" },
  { csv: "boost_psi",                 db: "boost_psi",                 label: "Boost Pressure (PSI)",        category: "engine",      presence: 100, required: false, new: false, notes: "" },
  { csv: "filter_oil_pressure",       db: "filter_oil_pressure",       label: "Filter Oil Pressure",         category: "engine",      presence: 100, required: false, new: true,  notes: "New field — added by migration" },
  { csv: "oil_temperature",           db: "oil_temperature",           label: "Oil Temperature (°F)",        category: "engine",      presence: 100, required: false, new: false, notes: "" },
  { csv: "oil_condition",             db: "oil_condition",             label: "Oil Condition Index",         category: "engine",      presence: 100, required: false, new: true,  notes: "New field — added by migration" },
  { csv: "intake_air_temperature",    db: "intake_air_temperature",    label: "Intake Air Temp (°F)",        category: "engine",      presence: 100, required: false, new: false, notes: "" },
  { csv: "fuel_temperature",          db: "fuel_temperature",          label: "Fuel Temperature (°F)",       category: "engine",      presence: 100, required: false, new: false, notes: "" },
  { csv: "throttle_position",         db: "throttle_position",         label: "Throttle Position %",         category: "engine",      presence: 69,  required: false, new: false, notes: "Partial — 69% of rows" },
  { csv: "system_voltage",            db: "system_voltage",            label: "System Voltage",              category: "engine",      presence: 100, required: false, new: false, notes: "" },
  // Fuel & consumption
  { csv: "fuel_gallons_per_hour",     db: "fuel_gallons_per_hour",     label: "Fuel Consumption (GPH)",      category: "fuel",        presence: 88,  required: false, new: false, notes: "Carbon credit calculations" },
  { csv: "fuel_level_percent",        db: "fuel_level_percent",        label: "Fuel Level %",                category: "fuel",        presence: 100, required: false, new: false, notes: "" },
  { csv: "fuel_gallons",              db: "fuel_gallons",              label: "Fuel Gallons (tank)",         category: "fuel",        presence: 100, required: false, new: false, notes: "" },
  { csv: "lifetime_fuel_consumption", db: "lifetime_fuel_consumption", label: "Lifetime Fuel (gal)",         category: "fuel",        presence: 100, required: false, new: false, notes: "" },
  { csv: "fuel_rate",                 db: "fuel_rate",                 label: "Fuel Rate",                   category: "fuel",        presence: 100, required: false, new: true,  notes: "New field — added by migration" },
  // Operational / lifetime
  { csv: "lifetime_operating_hours",  db: "lifetime_operating_hours",  label: "Lifetime Operating Hours",    category: "operational", presence: 100, required: false, new: false, notes: "Used for engine hours diagnostic" },
  { csv: "lifetime_idle_hours",       db: "lifetime_idle_hours",       label: "Lifetime Idle Hours",         category: "operational", presence: 100, required: false, new: true,  notes: "New field — added by migration" },
  { csv: "lifetime_idle_fuel",        db: "lifetime_idle_fuel",        label: "Lifetime Idle Fuel (gal)",    category: "operational", presence: 100, required: false, new: true,  notes: "New field — added by migration" },
  // Payload
  { csv: "truck_payload_tons",        db: "truck_payload_tons",        label: "Payload (tons)",              category: "payload",     presence: 56,  required: false, new: false, notes: "Carbon credit intensity calc" },
  { csv: "truck_miles_traveled",      db: "truck_miles_traveled",      label: "Miles Traveled",              category: "payload",     presence: 100, required: false, new: false, notes: "" },
  // Sparse / future
  { csv: "hydrocarbons",              db: "hydrocarbons",              label: "Hydrocarbons",                category: "sparse",      presence: 0,   required: false, new: true,  notes: "0% in this dataset — collect for future" },
  { csv: "heater_voltage",            db: "heater_voltage",            label: "Heater Voltage",              category: "sparse",      presence: 0,   required: false, new: true,  notes: "0% in this dataset" },
  { csv: "heater_current",            db: "heater_current",            label: "Heater Current",              category: "sparse",      presence: 0,   required: false, new: true,  notes: "0% in this dataset" },
  { csv: "smoke_setting",             db: "smoke_setting",             label: "Smoke Setting",               category: "sparse",      presence: 0,   required: false, new: true,  notes: "0% in this dataset" },
  // Summary rows
  { csv: "Load",       db: null, label: "Load (summary)",      category: "summary", presence: 0.5, required: false, new: false, notes: "Daily summary row — not per-reading" },
  { csv: "LoadCnt",    db: null, label: "Load Count",          category: "summary", presence: 0.5, required: false, new: false, notes: "Daily summary row" },
  { csv: "Fueling",    db: null, label: "Fueling",             category: "summary", presence: 0,   required: false, new: false, notes: "Daily summary row" },
  { csv: "Max",        db: null, label: "Max",                 category: "summary", presence: 0,   required: false, new: false, notes: "Daily summary row" },
  { csv: "Min",        db: null, label: "Min",                 category: "summary", presence: 0,   required: false, new: false, notes: "Daily summary row" },
  { csv: "Truck Hrs",  db: null, label: "Truck Hours",         category: "summary", presence: 0,   required: false, new: false, notes: "Daily summary row" },
  { csv: "Idle Hrs",   db: null, label: "Idle Hours",          category: "summary", presence: 0,   required: false, new: false, notes: "Daily summary row" },
  { csv: "Run Hrs",    db: null, label: "Run Hours",           category: "summary", presence: 0,   required: false, new: false, notes: "Daily summary row" },
  { csv: "Idle%",      db: null, label: "Idle %",              category: "summary", presence: 0,   required: false, new: false, notes: "Daily summary row" },
  { csv: "Miles",      db: null, label: "Miles",               category: "summary", presence: 0,   required: false, new: false, notes: "Daily summary row" },
  { csv: "Tons",       db: null, label: "Tons",                category: "summary", presence: 0,   required: false, new: false, notes: "Daily summary row" },
  { csv: "Loads",      db: null, label: "Loads",               category: "summary", presence: 0,   required: false, new: false, notes: "Daily summary row" },
  { csv: "TMG",        db: null, label: "TMG",                 category: "summary", presence: 0,   required: false, new: false, notes: "Daily summary row" },
];

const CATEGORIES = {
  iso8178:     { label: "ISO 8178 Detection",      color: "#1e40af", bg: "#dbeafe", icon: "⚡", desc: "Required for steady-state window detection" },
  emissions:   { label: "Emissions",               color: "#065f46", bg: "#d1fae5", icon: "💨", desc: "EBM algorithm inputs" },
  engine:      { label: "Engine Health",           color: "#7c2d12", bg: "#ffedd5", icon: "🔧", desc: "Temperature, pressure, electrical" },
  fuel:        { label: "Fuel & Consumption",      color: "#713f12", bg: "#fef9c3", icon: "⛽", desc: "Consumption rates and tank data" },
  operational: { label: "Operational / Lifetime",  color: "#4a1d96", bg: "#ede9fe", icon: "⏱",  desc: "Cumulative engine hour counters" },
  payload:     { label: "Payload & Productivity",  color: "#0f4c75", bg: "#e0f2fe", icon: "📦", desc: "Haul data for carbon intensity calc" },
  sparse:      { label: "Sparse / Future Use",     color: "#374151", bg: "#f3f4f6", icon: "🔮", desc: "0% in this dataset — store for future devices" },
  summary:     { label: "Daily Summary Rows",      color: "#9ca3af", bg: "#f9fafb", icon: "📋", desc: "Aggregated totals — not per-reading data" },
};

// Build default enabled state
const buildDefaults = () => {
  const map = {};
  ALL_COLUMNS.forEach(col => {
    map[col.csv] = col.category !== "summary" && col.presence > 0 && col.csv !== "co";
  });
  return map;
};

function PresenceBar({ pct }) {
  const color = pct === 0 ? "#e5e7eb" : pct < 50 ? "#fbbf24" : pct < 90 ? "#34d399" : "#10b981";
  return (
    <div className="flex items-center gap-1.5">
      <div style={{ width: 48, height: 4, background: "#e5e7eb", borderRadius: 2 }}>
        <div style={{ width: `${pct}%`, height: "100%", background: color, borderRadius: 2, transition: "width 0.3s" }} />
      </div>
      <span style={{ fontSize: 10, color: "#6b7280", fontFamily: "monospace", minWidth: 28 }}>{pct}%</span>
    </div>
  );
}

export default function ColumnSelector() {
  const [enabled, setEnabled] = useState(buildDefaults());
  const [saved, setSaved] = useState(false);
  const [activeCategory, setActiveCategory] = useState(null);
  const [showSummary, setShowSummary] = useState(false);

  const toggle = useCallback((csv, isRequired) => {
    if (isRequired) return;
    setEnabled(prev => ({ ...prev, [csv]: !prev[csv] }));
    setSaved(false);
  }, []);

  const toggleCategory = useCallback((cat) => {
    const catCols = ALL_COLUMNS.filter(c => c.category === cat && !c.required);
    const allOn = catCols.every(c => enabled[c.csv]);
    setEnabled(prev => {
      const next = { ...prev };
      catCols.forEach(c => { next[c.csv] = !allOn; });
      return next;
    });
    setSaved(false);
  }, [enabled]);

  const save = () => { setSaved(true); setTimeout(() => setSaved(false), 2500); };

  const enabledCount = Object.values(enabled).filter(Boolean).length;
  const totalMappable = ALL_COLUMNS.filter(c => c.category !== "summary").length;
  const newFieldCount = ALL_COLUMNS.filter(c => c.new && enabled[c.csv]).length;

  const visibleCategories = Object.keys(CATEGORIES).filter(cat =>
    cat !== "summary" || showSummary
  );

  return (
    <div style={{ fontFamily: "'IBM Plex Sans', system-ui, sans-serif", background: "#f8fafc", minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: "linear-gradient(135deg, #0f172a 0%, #1e3a5f 100%)", padding: "20px 28px" }}>
        <div style={{ maxWidth: 900, margin: "0 auto" }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <div>
              <div style={{ color: "#94a3b8", fontSize: 11, letterSpacing: "0.12em", textTransform: "uppercase", marginBottom: 4 }}>
                EBM AI · Telematics Import
              </div>
              <h1 style={{ color: "#fff", fontSize: 22, fontWeight: 700, margin: 0 }}>
                Column Import Configuration
              </h1>
              <div style={{ color: "#7dd3fc", fontSize: 13, marginTop: 3 }}>
                Redmond HT4 · Caterpillar C27 · Monico CSV
              </div>
            </div>
            <div style={{ textAlign: "right" }}>
              <div style={{ color: "#fff", fontSize: 26, fontWeight: 800 }}>{enabledCount}</div>
              <div style={{ color: "#94a3b8", fontSize: 11 }}>columns enabled</div>
              {newFieldCount > 0 && (
                <div style={{ marginTop: 4, background: "#7c3aed", color: "#fff", borderRadius: 4, padding: "2px 8px", fontSize: 11, display: "inline-block" }}>
                  +{newFieldCount} new DB fields
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 900, margin: "0 auto", padding: "20px 28px" }}>
        {/* Info banner */}
        <div style={{ background: "#fffbeb", border: "1px solid #fcd34d", borderRadius: 8, padding: "10px 14px", marginBottom: 18, display: "flex", alignItems: "center", gap: 10 }}>
          <span style={{ fontSize: 16 }}>ℹ️</span>
          <div style={{ fontSize: 13, color: "#92400e" }}>
            <strong>12,047 readings</strong> · 10-second intervals · Feb 5–8, 2018 · ISO 8178 thresholds: load ≥ 90% · RPM ≥ 1750
            <span style={{ marginLeft: 12, color: "#b45309" }}>276 qualifying rows (2.3%) → ~39 valid tests</span>
          </div>
        </div>

        {/* Category tabs */}
        <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginBottom: 18 }}>
          <button
            onClick={() => setActiveCategory(null)}
            style={{
              padding: "5px 12px", borderRadius: 20, fontSize: 12, fontWeight: 600, cursor: "pointer", border: "none",
              background: activeCategory === null ? "#1e40af" : "#e2e8f0",
              color: activeCategory === null ? "#fff" : "#475569",
              transition: "all 0.15s"
            }}
          >
            All Categories
          </button>
          {Object.entries(CATEGORIES).filter(([k]) => k !== "summary").map(([key, cat]) => {
            const count = ALL_COLUMNS.filter(c => c.category === key && enabled[c.csv]).length;
            const total = ALL_COLUMNS.filter(c => c.category === key).length;
            return (
              <button
                key={key}
                onClick={() => setActiveCategory(activeCategory === key ? null : key)}
                style={{
                  padding: "5px 12px", borderRadius: 20, fontSize: 12, fontWeight: 600,
                  cursor: "pointer", border: "2px solid",
                  borderColor: activeCategory === key ? cat.color : "transparent",
                  background: activeCategory === key ? cat.bg : "#e2e8f0",
                  color: activeCategory === key ? cat.color : "#475569",
                  transition: "all 0.15s"
                }}
              >
                {cat.icon} {cat.label} <span style={{ opacity: 0.7 }}>({count}/{total})</span>
              </button>
            );
          })}
        </div>

        {/* Column groups */}
        {visibleCategories
          .filter(cat => activeCategory === null || cat === activeCategory)
          .map(cat => {
            const catDef = CATEGORIES[cat];
            const catCols = ALL_COLUMNS.filter(c => c.category === cat);
            const allOn = catCols.filter(c => !c.required).every(c => enabled[c.csv]);
            const someOn = catCols.some(c => enabled[c.csv]);

            return (
              <div key={cat} style={{ marginBottom: 16, borderRadius: 10, overflow: "hidden", border: `1px solid ${catDef.bg === "#f9fafb" ? "#e5e7eb" : catDef.bg}`, boxShadow: "0 1px 3px rgba(0,0,0,0.06)" }}>
                {/* Category header */}
                <div style={{ background: catDef.bg, padding: "10px 16px", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                    <span style={{ fontSize: 18 }}>{catDef.icon}</span>
                    <div>
                      <div style={{ fontWeight: 700, color: catDef.color, fontSize: 13 }}>{catDef.label}</div>
                      <div style={{ fontSize: 11, color: catDef.color, opacity: 0.8 }}>{catDef.desc}</div>
                    </div>
                  </div>
                  {cat !== "summary" && catCols.some(c => !c.required) && (
                    <button
                      onClick={() => toggleCategory(cat)}
                      style={{
                        padding: "4px 12px", borderRadius: 6, fontSize: 11, fontWeight: 600,
                        cursor: "pointer", border: `1px solid ${catDef.color}40`,
                        background: allOn ? catDef.color : "transparent",
                        color: allOn ? "#fff" : catDef.color,
                        transition: "all 0.15s"
                      }}
                    >
                      {allOn ? "Deselect All" : someOn ? "Select All" : "Select All"}
                    </button>
                  )}
                </div>

                {/* Column rows */}
                <div style={{ background: "#fff" }}>
                  {catCols.map((col, i) => {
                    const isEnabled = enabled[col.csv];
                    const isRequired = col.required;
                    const hasNoData = col.presence === 0;

                    return (
                      <div
                        key={col.csv}
                        onClick={() => toggle(col.csv, isRequired)}
                        style={{
                          display: "flex", alignItems: "center", padding: "9px 16px",
                          borderTop: i > 0 ? "1px solid #f1f5f9" : "none",
                          cursor: isRequired ? "default" : "pointer",
                          background: isEnabled ? "#fff" : "#fafafa",
                          opacity: hasNoData && !isEnabled ? 0.5 : 1,
                          transition: "background 0.1s",
                        }}
                      >
                        {/* Checkbox */}
                        <div style={{
                          width: 18, height: 18, borderRadius: 4, border: `2px solid`,
                          borderColor: isEnabled ? catDef.color : "#d1d5db",
                          background: isEnabled ? catDef.color : "#fff",
                          display: "flex", alignItems: "center", justifyContent: "center",
                          flexShrink: 0, transition: "all 0.15s", marginRight: 12
                        }}>
                          {isEnabled && <svg width="10" height="8" viewBox="0 0 10 8"><path d="M1 4l3 3 5-6" stroke="#fff" strokeWidth="1.8" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>}
                        </div>

                        {/* Label */}
                        <div style={{ flex: 1, minWidth: 0 }}>
                          <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
                            <span style={{ fontWeight: 600, fontSize: 13, color: isEnabled ? "#111827" : "#9ca3af" }}>
                              {col.label}
                            </span>
                            {isRequired && (
                              <span style={{ background: "#dbeafe", color: "#1e40af", fontSize: 10, fontWeight: 700, padding: "1px 5px", borderRadius: 3 }}>REQUIRED</span>
                            )}
                            {col.new && (
                              <span style={{ background: "#ede9fe", color: "#7c3aed", fontSize: 10, fontWeight: 700, padding: "1px 5px", borderRadius: 3 }}>NEW FIELD</span>
                            )}
                          </div>
                          {col.notes && (
                            <div style={{ fontSize: 11, color: "#9ca3af", marginTop: 1 }}>{col.notes}</div>
                          )}
                        </div>

                        {/* CSV column name */}
                        <div style={{ fontFamily: "monospace", fontSize: 11, color: "#94a3b8", marginRight: 16, flexShrink: 0 }}>
                          {col.csv}
                        </div>

                        {/* Presence bar */}
                        <div style={{ flexShrink: 0 }}>
                          <PresenceBar pct={col.presence} />
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            );
          })}

        {/* Summary rows toggle */}
        {activeCategory === null && (
          <button
            onClick={() => setShowSummary(s => !s)}
            style={{
              background: "none", border: "1px dashed #d1d5db", borderRadius: 8,
              padding: "8px 16px", color: "#9ca3af", fontSize: 12, cursor: "pointer",
              width: "100%", marginBottom: 16
            }}
          >
            {showSummary ? "▲ Hide" : "▼ Show"} Daily Summary Rows (13 columns — always skipped)
          </button>
        )}

        {/* Save bar */}
        <div style={{
          position: "sticky", bottom: 16,
          background: "#1e293b", borderRadius: 12,
          padding: "14px 20px", display: "flex", alignItems: "center", justifyContent: "space-between",
          boxShadow: "0 4px 24px rgba(0,0,0,0.25)"
        }}>
          <div>
            <span style={{ color: "#fff", fontWeight: 700, fontSize: 15 }}>
              {enabledCount} columns selected
            </span>
            <span style={{ color: "#94a3b8", fontSize: 13, marginLeft: 10 }}>
              of {totalMappable} importable · {newFieldCount} new DB fields required
            </span>
          </div>
          <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
            {saved && (
              <div style={{ color: "#34d399", fontWeight: 600, fontSize: 13 }}>✓ Configuration saved</div>
            )}
            <button
              onClick={save}
              style={{
                background: "#3b82f6", color: "#fff", border: "none",
                padding: "9px 22px", borderRadius: 8, fontWeight: 700, fontSize: 14,
                cursor: "pointer", transition: "background 0.15s"
              }}
            >
              Save & Apply
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
