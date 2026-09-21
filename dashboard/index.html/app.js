const API_BASE = "http://localhost:5000";

document.getElementById('announcementForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const payload = {
        title: document.getElementById('annTitle').value,
        content: document.getElementById('annContent').value,
        secretary_id: "TW-2026-001" // Logged in user context
    };

    const response = await fetch(`${API_BASE}/announcements`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    });

    const result = await response.json();
    if(result.status === "success") {
        alert("Announcement posted to all group members!");
        e.target.reset();
    }
});

async function fetchFinancials() {
    // API Call to fetch ledger balance
    console.log("Fetching latest ledger information...");
}