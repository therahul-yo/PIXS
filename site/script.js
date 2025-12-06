const cursor = document.getElementById('cursor-follower');
const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');

let width = window.innerWidth;
let height = window.innerHeight;

canvas.width = width;
canvas.height = height;

// Resize handling
window.addEventListener('resize', () => {
    width = window.innerWidth;
    height = window.innerHeight;
    canvas.width = width;
    canvas.height = height;
    initParticles();
});

// Cursor Tracking with slight delay for "Ghost" effect
let mouseX = width / 2;
let mouseY = height / 2;
let cursorX = width / 2;
let cursorY = height / 2;

document.addEventListener('mousemove', (e) => {
    mouseX = e.clientX;
    mouseY = e.clientY;
});

function updateCursor() {
    // Lerp for smooth following
    const dx = mouseX - cursorX;
    const dy = mouseY - cursorY;
    
    cursorX += dx * 0.25;
    cursorY += dy * 0.25;
    
    cursor.style.left = cursorX + 'px';
    cursor.style.top = cursorY + 'px';
    
    // Funny rotation based on movement
    const angle = Math.atan2(dy, dx) * 180 / Math.PI;
    // Only rotate if moving fast enough
    if (Math.abs(dx) > 1 || Math.abs(dy) > 1) {
        cursor.style.transform = `translate(-50%, -50%) rotate(${angle}deg)`;
    } else {
        cursor.style.transform = `translate(-50%, -50%) rotate(0deg)`;
    }
    
    requestAnimationFrame(updateCursor);
}
updateCursor();

// Canvas Constellation Animation
const particles = [];
const particleCount = 60;
const connectionDistance = 150;
const mouseDistance = 200;

class Particle {
    constructor() {
        this.x = Math.random() * width;
        this.y = Math.random() * height;
        this.vx = (Math.random() - 0.5) * 0.5;
        this.vy = (Math.random() - 0.5) * 0.5;
        this.size = Math.random() * 2 + 1;
    }

    update() {
        this.x += this.vx;
        this.y += this.vy;

        // Bounce off edges
        if (this.x < 0 || this.x > width) this.vx *= -1;
        if (this.y < 0 || this.y > height) this.vy *= -1;

        // Mouse interaction: flee from mouse? or attract to mouse?
        // Let's make them connect to mouse
    }

    draw() {
        ctx.fillStyle = 'rgba(255, 255, 255, 0.5)';
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fill();
    }
}

function initParticles() {
    particles.length = 0;
    for (let i = 0; i < particleCount; i++) {
        particles.push(new Particle());
    }
}

function animateParticles() {
    ctx.clearRect(0, 0, width, height);

    for (let i = 0; i < particles.length; i++) {
        particles[i].update();
        particles[i].draw();

        // Connect to other particles
        for (let j = i; j < particles.length; j++) {
            const dx = particles[i].x - particles[j].x;
            const dy = particles[i].y - particles[j].y;
            const distance = Math.sqrt(dx * dx + dy * dy);

            if (distance < connectionDistance) {
                ctx.strokeStyle = `rgba(255, 255, 255, ${1 - distance / connectionDistance})`;
                ctx.lineWidth = 0.5;
                ctx.beginPath();
                ctx.moveTo(particles[i].x, particles[i].y);
                ctx.lineTo(particles[j].x, particles[j].y);
                ctx.stroke();
            }
        }

        // Connect to mouse (cursorX, cursorY)
        const dx = particles[i].x - cursorX;
        const dy = particles[i].y - cursorY;
        const distance = Math.sqrt(dx * dx + dy * dy);

        if (distance < mouseDistance) {
            ctx.strokeStyle = `rgba(255, 255, 255, ${(1 - distance / mouseDistance) * 0.5})`;
            ctx.lineWidth = 0.5;
            ctx.beginPath();
            ctx.moveTo(particles[i].x, particles[i].y);
            ctx.lineTo(cursorX, cursorY);
            ctx.stroke();
        }
    }

    requestAnimationFrame(animateParticles);
}

initParticles();
animateParticles();

// Copy command to clipboard
function copyCommand() {
    const cmd = document.getElementById('install-cmd').textContent;
    navigator.clipboard.writeText(cmd).then(() => {
        const btn = document.querySelector('.copy-btn');
        btn.textContent = '✅';
        setTimeout(() => btn.textContent = '📋', 1500);
    });
}
