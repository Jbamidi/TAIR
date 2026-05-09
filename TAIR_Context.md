# TAIR — Master Context Document
**Last Updated:** May 8, 2026
**Version:** 3.0
**Purpose:** Drop this into any new chat to give full context on TAIR. Update it as the project evolves.

---

## What Changed in v3.0 (since v2.0)

- **Team:** Andrew is no longer with the team. Hemal works full-time at Workday (CS) — TAIR is evening/weekend work for him. TAIR is now a 2-founder team.
- **GTM:** Broadened from cold-chain-only to a dual-track strategy. Cold chain/pharma remains the headline pitch story; general warehouse storage is the early-pilot/case-study track.
- **Phase 1 BOM:** RFID deferred to Phase 2. Phase 1 is LiDAR + IMU + barcode (USB webcam + pyzbar). M6E Nano discontinued; YRM100 ($50-90) is the planned Phase 2 UHF replacement. Realistic Phase 1 BOM is ~$450-700 not $250.
- **Web/brand:** Domain registered as `tairsystems.com`. Logo direction locked: serpentine drone-path mark with starting dot (top-left) and directional arrow (bottom-right), single cyan `#00D4FF` accent on near-black `#0A0A0B`. Built marketing site in Next.js 14 + R3F via Antigravity.
- **Tooling decision:** Mac (or Linux) preferred for development. If Windows is unavoidable, develop entirely on the Rubik Pi via VS Code Remote SSH.

---

## Table of Contents
1. [Company Identity](#1-company-identity)
2. [The Team](#2-the-team)
3. [The Problem](#3-the-problem)
4. [The Solution](#4-the-solution)
5. [The Full Ecosystem](#5-the-full-ecosystem)
6. [How the Drone Flies Indoors](#6-how-the-drone-flies-indoors)
7. [Business Model & Pricing](#7-business-model--pricing)
8. [Go-To-Market Strategy](#8-go-to-market-strategy)
9. [Competitive Landscape](#9-competitive-landscape)
10. [Technical Stack](#10-technical-stack)
11. [ROS2 Workspace & Setup](#11-ros2-workspace--setup)
12. [Hardware Status](#12-hardware-status)
13. [Build Roadmap](#13-build-roadmap)
14. [Obstacle Detection Architecture](#14-obstacle-detection-architecture)
15. [Known Technical Risks & Pitfalls](#15-known-technical-risks--pitfalls)
16. [Funding & Grant Applications](#16-funding--grant-applications)
17. [Jashwanth's Background](#17-jashwanths-background)
18. [Brand & Web Presence](#18-brand--web-presence)
19. [Key Decisions Log](#19-key-decisions-log)
20. [Pitch Materials](#20-pitch-materials)

---

## 1. Company Identity

**Name:** TAIR
**Domain:** tairsystems.com
**Type:** Autonomous Indoor Intelligence Platform
**Stage:** Pre-seed, Phase 1 (Ground Cart POC)
**GitHub:** https://github.com/Jbamidi/TAIR (private, renamed from Indoor-Drone-Startup)
**Founded:** 2026 by two UIUC engineering students

### Core Identity Statement
TAIR is an autonomous indoor intelligence platform. Drone-based spatial mapping is the data collection layer that powers it. The mapping is the mechanism — the intelligence is the product.

TAIR is not just a drone company. It is a complete warehouse intelligence ecosystem: autonomous drone fleet + RFID tag network + fixed anchor sensors + cloud backend + AI intelligence layer + React/Three.js digital twin dashboard + deep WMS integrations. The drone is how we collect data. The platform is what we sell.

### The One-Line Pitch
Warehouses lose millions annually because their WMS is always wrong — industry average inventory accuracy is just 68%. TAIR fixes that overnight, autonomously, with zero workflow changes for warehouse staff.

### Tagline
**Inventory that knows itself.**

### The Three-Layer Value Proposition

**Layer 1 — Spatial Accuracy (The Foundation)**
We give operators an accurate, always-current digital representation of their facility. Accurate maps mean better WMS routing, better robot navigation, and fewer wasted labor hours.

**Layer 2 — Inventory Intelligence (The Product)**
RFID + barcode reads on every nightly scan, reconciled against the WMS, surfacing discrepancies before the morning shift. The corrected inventory is pushed back to the WMS automatically.

**Layer 3 — Defensible Data Moat (The Long Game)**
Every scan trains our ML reconciliation model. Customer historical data + facility maps + scan history compound — competitors start from zero, we start with years of context.

---

## 2. The Team

**Two founders. Both technical.**

### Jashwanth Bamidi — Co-Founder, Hardware
- Electrical & Computer Engineering, University of Illinois Urbana-Champaign
- GPA 3.84
- Born India, moved to US at age 5
- Hardware lead: PCB design, firmware, sensor integration, mechanical
- Background: analog guitar auto-tuner (op-amp gyrators, bandpass filters, no microcontroller), pipelined RISC-V CPU (3.8x throughput improvement), FPGA computer vision pipeline (99% compute reduction)
- Leads PCB design at Eco Illini and Illini EV Concept (UIUC student vehicle teams)
- Git identity: `jbamidi@illinois.edu`
- Current location: Champaign for ~4 weeks, then Bay Area for summer

### Hemal — Co-Founder, Software
- Computer Science background
- Full-time CS engineer at Workday (day job, not relevant to TAIR context)
- TAIR work happens evenings/weekends — bandwidth is real and limited
- Develops on Mac Mini M4 via VS Code Remote SSH
- Software lead: ROS2 nodes, FastAPI backend, ML pipeline, React/Three.js dashboard
- Currently in the Bay Area

### Roles Breakdown

| Domain | Owner |
|---|---|
| Hardware (chassis, sensors, wiring, PCB) | Jashwanth |
| Embedded firmware, ROS2 nodes for sensors | Jashwanth |
| ROS2 simulation, SLAM tuning | Hemal |
| FastAPI + PostgreSQL backend | Hemal |
| React + Three.js dashboard | Hemal |
| Cloud deployment (Railway, Vercel) | Hemal |
| Pitch materials, grant applications | Jashwanth |
| Investor outreach | Jashwanth |
| Mechanical CAD / 3D printing | Jashwanth |

### Former team
- **Andrew (ECE, UIUC)** — formerly handled sensors/firmware/PCB. No longer with the team. His former responsibilities now fall to Jashwanth.

### Coordination model
- Daily async standup in Slack/Discord, 5 min text-only at end of day
- Weekly 30-min sync call
- Repo branch hygiene: Jashwanth on `jashwanth/phase1-setup`, Hemal on `hemal/phase1-setup`
- INTERFACE.md in repo defines all ROS2 topic names, message types, TF frame names, FastAPI endpoint shapes — single source of truth to prevent integration mismatches

---

## 3. The Problem

The warehouse industry runs on broken data.

**Industry-average inventory accuracy: 68%.** That means roughly one in three records in a warehouse management system is wrong. Wrong location. Wrong count. Wrong SKU.

**Annual cost of inventory inaccuracy globally: $1.1 trillion.** Includes mis-picks, expedited shipping, customer churn, manual reconciliation labor, lost sales from "out of stock" items that are actually in the building.

**Cycle count labor per large facility: $500K – $2M/year.** Manual cycle counting is the legacy fix — humans walking aisles with handheld scanners. It scales poorly, fights with daily operations, and is itself error-prone.

**The math:** A 1% inventory accuracy improvement is worth $685K – $1.52M annually for a mid-size 3PL operation. TAIR's pricing has to fit comfortably inside that gap. It does.

### Why it's broken (root cause)

WMS data degrades the moment a pallet moves. Workers move things off-procedure. Mis-picks compound. By the next cycle count, the WMS is a fiction. Manual cycle counts can't keep up with daily SKU velocity in modern e-commerce.

### Who feels it most acutely

- **Cold chain/pharma 3PLs** — FDA DSCSA traceability requirements turn inventory inaccuracy into regulatory risk, not just operational cost
- **High-velocity e-commerce fulfillment** — every mis-pick is a refund + return shipping + Amazon performance penalty
- **Multi-tenant 3PLs** — when inventory goes missing, no neutral source of truth means lawyers, chargebacks, lost accounts

---

## 4. The Solution

A nightly autonomous drone (Phase 2) — for now, a manually-pushed ground cart (Phase 1) — scans the warehouse with LiDAR + barcode + (eventually) RFID. Builds a digital twin. Reconciles against the WMS. Pushes corrected inventory data before the morning shift.

The drone is the sensor. The platform is the product.

### What the customer experiences

1. Install: anchor sensors mounted on racks, RFID tags applied to pallets (Phase 2+), drone dock placed in the corner
2. Operate: nothing changes for warehouse staff. Drone runs at night when the facility is empty
3. Receive: morning report shows inventory accuracy improvements, surfaced discrepancies, and recommended actions
4. WMS sync: corrections push automatically into existing systems (Extensiv first, more to come)

---

## 5. The Full Ecosystem

```
┌─────────────────────────────────────────────────────────────┐
│                         TAIR PLATFORM                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   Data Collection Layer (the drone — Phase 2)                │
│   ├── LiDAR (STL27L, 25m range, 21,600 pts/sec)             │
│   ├── IMU (MPU-9250)                                         │
│   ├── Barcode camera (USB webcam + pyzbar)                  │
│   ├── UHF RFID reader (YRM100 — Phase 2 addition)           │
│   └── Optical flow + rangefinders (Phase 2 flight stack)    │
│                                                              │
│   Intelligence Layer (the platform — the product)            │
│   ├── ROS2 onboard processing (slam-toolbox, Nav2)          │
│   ├── FastAPI backend + PostgreSQL                           │
│   ├── ML reconciliation engine                               │
│   ├── Digital twin (React + Three.js)                        │
│   └── WMS integrations (Extensiv first)                      │
│                                                              │
│   Defensibility Layer                                        │
│   ├── Data flywheel (ML improves with every scan)           │
│   ├── Customer historical data lock-in                       │
│   ├── Facility map lock-in                                   │
│   └── RFID tag deployment lock-in (Phase 2+)                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. How the Drone Flies Indoors

**Phase 1 (current):** Ground cart, manually pushed. No flight.

**Phase 2 (Bay Area, summer):** Holybro X500 V2 + Pixhawk 6C Mini + PX4 + MAVROS.

### Indoor flight stack (no GPS)

- **PX4Flow optical flow sensor** for visual-inertial odometry
- **VL53L1X laser rangefinders** (multiple) for height + obstacle distance
- **PX4 EKF2** fuses optical flow + rangefinders + IMU for indoor position estimate
- **MAVROS** bridges PX4 → ROS2 for high-level autonomy
- **Geofencing** via SLAM-derived facility map — drone never approaches walls/racking

### Why no SLAM-based flight (yet)

SLAM-on-drone with feature-sparse warehouse environments is an open research problem. Phase 2's first flight uses geofence-based safety + waypoint navigation. SLAM-derived flight comes in Phase 2.5 once we've proven the basic platform.

---

## 7. Business Model & Pricing

**SaaS subscription, hardware-leased.**

| Tier | Price | Target | Key Features |
|---|---|---|---|
| **Starter** | $3,500/mo | General warehouse storage, mid-market 3PLs (50K-200K sqft) | Nightly autonomous scan, basic dashboard, barcode + LiDAR, single WMS integration |
| **Professional** | $8,000/mo | Cold chain, pharma 3PLs, premium operations | Adds RFID, FDA-compliant reporting, thermal-rated hardware, dedicated support |
| **Enterprise** | $20,000+/mo | Large facilities, multi-site deployments | Multiple drones, custom integrations, on-site engineer |

**Target gross margin: ~71%.**

Hardware (the drone, anchors, dock) is leased and amortized over the contract. Customer pays for the platform, not the hardware. This makes upgrades non-disruptive and locks customers into the SaaS revenue stream rather than a one-time hardware sale.

---

## 8. Go-To-Market Strategy

**Dual-track approach** — sharper story than v2.0's "cold-chain-only" framing, more honest execution.

### Track 1 — Cold Chain / Pharma (Headline Vertical)

**Why:** FDA DSCSA + cold-chain temperature compliance = forcing function. Buyers don't have a choice. RFID through condensation + packaging = real technical advantage where camera-only competitors fail. Premium pricing tier ($8K-20K) supported by compliance budgets.

**Use:** Investor pitch sections, grant applications, gradCapital narrative, "why now" answer in every cold email.

### Track 2 — General Warehouse Storage (Volume Pilot Track)

**Why:** Faster sales cycle, lower regulatory friction, easier first-customer access. 150K+ US facilities. Mid-market 3PLs (50K-200K sqft) are the sweet spot — too small to build in-house, too big to ignore the pain. Their WMS is usually Extensiv or 3PL Central with documented APIs. They're owner-operated; you can reach the decision-maker on LinkedIn.

**Use:** First Bay Area summer pilots. Build case studies and traction. The proof points that unlock cold chain conversations.

### Sequencing (not parallelism)

**May–Sept 2026:**
- Build: room-temp Phase 1 hardware, no thermal enclosures
- Pilot: 1 free Bay Area general-storage 3PL, 30-day, get a testimonial + scan data
- Pitch: cold chain pharma in all investor/grant materials

**Sept–Dec 2026:**
- Build: thermal enclosure, battery heating, sealed RFID
- Pitch: cold chain conversations now backed by "running in production at [General Storage 3PL]"
- Pilot: first cold-chain LOI

**Q1 2027:**
- Convert: first paying cold-chain customer at $8-20K/mo
- Volume: 2-3 general storage customers at $3,500/mo

### Buyer Map

| Role | Importance | Approach |
|---|---|---|
| Ops Manager | **Champion** — feels the pain daily, gets the demo first | Lead with operational ROI |
| VP Ops / COO | **Economic Buyer** — signs the check | Lead with $/year savings |
| IT | **Blocker** — controls WMS, fears integration | De-risk: "we have a documented Extensiv integration, takes 2 hours" |

### First WMS integration: **Extensiv**
Mid-market 3PL favorite. Documented REST API. Smaller customer base than SAP EWM but easier integration and faster sales cycles.

---

## 9. Competitive Landscape

### Primary competitor: Gather AI

- $74M raised (Series B)
- CMU spinout
- Camera-only (no RFID)
- Requires human operator per aisle (not lights-out autonomous)
- Plays primarily in general warehouse storage

### Where TAIR wins

1. **Lights-out autonomy** — no operator per aisle. Runs all night unattended. Dock-and-recharge.
2. **RFID layer** — reads through cardboard, plastic wrap, condensation. Camera-only fails in cold storage and dense racking.
3. **Cold chain niche** — Gather AI doesn't focus there because cameras struggle in condensation. We made it our wedge.
4. **Price** — Starter at $3,500/mo opens a market segment Gather AI's enterprise-priced product can't reach profitably.
5. **Speed of deployment** — small team, fast install, simple integrations.

### Other players (less relevant, but tracked)

- Corvus Robotics — drone-based inventory, similar approach, smaller footprint
- Verity — Switzerland-based, drone-based, enterprise-priced
- Dexory — UK-based, ground-robot inventory scanning
- Simbe Robotics — focused on retail, not warehouse
- Pensa, Vimaan, Eyesee — similar space, varying approaches

### Competitive moat (5-layered)

1. **Data flywheel** — every scan improves the ML reconciliation engine
2. **WMS integration stickiness** — once integrated, ripping out breaks operations
3. **Switching cost** — historical scan data + facility evolution data is locked in
4. **Hardware lock-in (Phase 2+)** — RFID tags on thousands of pallets is itself a moat
5. **Facility map** — competitor entering a facility starts from zero, we have years of map history

---

## 10. Technical Stack

### Hardware compute
- **Thundercomm Rubik Pi 3** (QCS6490, 8GB RAM, 12 TOPS NPU, Ubuntu 24.04)

### Robotics middleware
- **ROS2 Jazzy** (not Humble — Jazzy is the current LTS)
- **slam-toolbox** for 2D SLAM (not Hector SLAM, not Cartographer for Phase 1)
- **Nav2** for navigation (Phase 1.5+)
- **tf2** for coordinate frames

### ROS2 nodes (Phase 1)
- `tair_bringup` — master launch package, brings up all 4 nodes
- `ldlidar_stl_ros2` — STL27L LiDAR driver. **Fix:** add `#include <pthread.h>` for GCC 13
- `ros2_mpu6050_driver` — IMU driver. **Fix:** add `#include <array>` for GCC 13
- `tair_barcode` — barcode detection node, USB webcam + pyzbar (replaces RFID for Phase 1)
- `tair_rfid` — UHF RFID node (Phase 2+, deferred)

### SLAM configuration
- Resolution: 0.05m
- Max range: 20m
- Loop closure: enabled
- Tuned for warehouse environments (large featureless aisles, repetitive racking)

### Cloud backend (Hemal's domain)
- **FastAPI** (Python) for REST API
- **PostgreSQL** for primary data store
- **Railway** for backend hosting
- Schema (Phase 1): scans, detections, facilities, maps tables

### Frontend (Hemal's domain)
- **Next.js 14** (App Router)
- **React** + **TypeScript**
- **Three.js** + **@react-three/fiber** + **@react-three/drei** for digital twin 3D
- **Tailwind CSS** for styling
- **Vercel** for frontend hosting

### Development environment
- **Mac (Apple Silicon) preferred** — Hemal's Mac Mini M4 runs ROS2 Jazzy in ARM64 Docker, matching the Rubik Pi's architecture
- **Linux (Ubuntu 24.04) is technically optimal** — same as Rubik Pi. Use if available.
- **Windows is acceptable only via VS Code Remote SSH into the Rubik Pi** — do not install ROS2 natively on Windows, do not use WSL2 for ROS2 (USB passthrough + DDS multicast issues)
- **`.gitattributes` with `* text=auto eol=lf`** to prevent CRLF/LF issues across mixed OS team

---

## 11. ROS2 Workspace & Setup

### Rubik Pi access
- SSH: `ubuntu@rubikpi.local`
- Workspace: `~/tair_ws/`
- Repo: `~/TAIR_Github/`
- Active branch: `jashwanth/phase1-setup`

### Build commands
```bash
cd ~/tair_ws
colcon build --packages-select tair_bringup
source install/setup.bash
ros2 launch tair_bringup tair_bringup.launch.py
```

### Critical driver fixes (must apply before colcon build)

**LiDAR driver fix:**
```bash
# In ldlidar_stl_ros2/include/ldlidar_driver/ldlidar_driver.h
# Add at top of file:
#include <pthread.h>
```

**IMU driver fix:**
```bash
# In ros2_mpu6050_driver/include/mpu6050driver/mpu6050driver.hpp
# Add at top of file:
#include <array>
```

Both fixes are required for GCC 13 (default on Ubuntu 24.04). Without them, colcon build fails with cryptic template errors.

### Sensor port assignments (Phase 1)
- LiDAR: `/dev/ttyUSB0`, baud 921600
- IMU: I2C bus 1, address 0x68
- Barcode camera: `/dev/video0` (USB webcam)
- RFID: deferred to Phase 2

### TF tree (Phase 1)
```
base_link
├── base_laser    (offset: 0, 0, 0.18m)  — LiDAR mount height 18cm
├── imu_link      (offset: 0, 0, 0.05m)  — IMU below LiDAR
└── camera_link   (offset: 0.10, 0, 0.10m) — barcode cam forward-mounted
```

---

## 12. Hardware Status

### Phase 1 Ground Cart BOM (revised May 2026)

**Tier 1 — Compute & sensors (critical)**
| Item | Source | Cost |
|---|---|---|
| Thundercomm Rubik Pi 3 (8GB) | Already owned | — |
| STL27L 360° LiDAR + USB-TTL adapter | Amazon `B0C74CRWYS` or Waveshare | $128–168 |
| MPU-9250 IMU breakout × 2 (one spare) | Amazon (HiLetgo) | $18 |
| Logitech C270 USB webcam (barcode) | Amazon | $20–25 |

**Tier 2 — Power**
| Item | Cost |
|---|---|
| Anker 737 (24K mAh, 140W USB-C PD) | $130 |
| USB-C 100W cables × 2 | $15 |
| USB-A short cable | $5 |

**Tier 3 — Mechanical**
| Item | Cost |
|---|---|
| 4WD aluminum chassis (200x200mm platform) | $55–75 |
| Acrylic top mounting plate (or 3D print) | $0–15 |
| Push handle | $10–15 |

**Tier 4 — Wiring & misc**
| Item | Cost |
|---|---|
| M2.5 + M3 standoff/screw kits | $27 |
| Dupont jumpers | $10 |
| Heat shrink + tape + zip ties | $16 |
| Powered USB hub | $15 |

**Tier 5 — Tools** (skip if already in Bay): $165–230

**Tier 6 — Networking**
| Item | Cost |
|---|---|
| GL.iNet Beryl AX travel router | $90 |
| Ethernet cables × 2 | $10 |
| Micro HDMI cable, MicroSD backup | $20 |

**Tier 7 — Consumables:** ~$28

**Total (Tools assumed already owned):** ~$447–682
**Total (with full tool kit):** ~$612–912

Maker grant ($250) covers Tier 1 only. Awesome Foundation ($1K, if approved) covers the rest plus seeds Phase 2.

### Phase 1: NO RFID

RFID is deferred to Phase 2 alongside the drone build. Phase 1 demonstrates SLAM + barcode-based identification — sufficient for proving the autonomous mapping pipeline. RFID is a known commodity once you have the right reader; SLAM is the hard, novel demo.

### Phase 2 RFID plan
- **YRM100 USB UHF reader** ($50-90, US 902-928 MHz / EU 865-868 MHz, EPC Gen 2, >50 tags/sec)
- **NOT** the SparkFun M6E Nano (officially retired by SparkFun)
- **NOT** a PN532 — that's a 13.56 MHz NFC/HF reader (5cm range, single tag at a time, useless for warehouse use)
- Order 2 of any cheap Chinese RFID module — DOA rates ~5-10%

### Phase 2 flight hardware (deferred to Bay summer)
- Holybro X500 V2 frame
- Pixhawk 6C Mini flight controller
- PX4Flow optical flow sensor
- VL53L1X laser rangefinders (multiple)
- LiPo batteries with thermal headroom

---

## 13. Build Roadmap

### Phase 1 — Ground Cart POC (current, May–early June 2026)

**Pre-Bay (next ~4 weeks, in Champaign):**
1. Verify ROS2 stack still builds clean on Rubik Pi
2. Order all Phase 1 hardware to Bay address (NOT to Champaign first)
3. Hemal: Local Mac dev environment, ROS2 Jazzy in ARM64 Docker
4. Hemal: Gazebo + TurtleBot3 simulation, full SLAM pipeline working in sim
5. Hemal: FastAPI + PostgreSQL backend scaffold, Railway deployment
6. Hemal: React + Three.js dashboard skeleton, Vercel deployment
7. Jashwanth: ROS2 nodes for sensors (skeleton), mechanical assembly plan on paper, wiring map drawn
8. Jashwanth: gradCapital video (4-day deadline, personal story)
9. INTERFACE.md committed to repo
10. Awesome Foundation $1K follow-up

**Bay Week 1 (target: late May / early June):**
- Day 1: Mechanical assembly, cart powered up, SSH from Mac confirmed
- Day 2: LiDAR live, point cloud visible in RViz2
- Day 3: IMU wired, TF tree complete
- Day 4: Full SLAM run, first real-world map saved (apartment / hallway / parking garage)
- Day 5: Barcode integration, full sensor pipeline running together
- Day 6: End-to-end demo, ROS bag recorded, video recorded
- Day 7: Buffer / debug / Phase 2 hardware ordering

**Bay Weeks 2–4:**
- Bay Area 3PL outreach for free 30-day general-storage pilot
- Phase 2 hardware arrives, drone build begins

### Phase 2 — Autonomous Drone (Bay summer, June–Aug 2026)
- Holybro X500 + Pixhawk 6C Mini + PX4
- Indoor flight via PX4Flow + VL53L1X
- RFID added (YRM100)
- First flight in controlled space
- First customer pilot (general storage 3PL)

### Phase 2.5 — Cold Chain Hardware (Sept–Dec 2026)
- Thermal enclosure for electronics
- Battery heating
- Condensation-sealed RFID
- First cold-chain LOI

### Phase 3 — First Paying Customer (Q1 2027)
- Cold chain customer signed at $8-20K/mo
- Anchor sensors deployed
- Multi-drone logic begins

### Phase 4 — Enterprise (mid-2027+)
- Custom integrations beyond Extensiv
- Multi-site deployments
- $20K+/mo tier

---

## 14. Obstacle Detection Architecture

### Phase 1 (ground cart)
- 2D LiDAR provides 360° obstacle detection in horizontal plane
- IMU detects tilt / collision shock
- Manual push, so human operator handles obstacle avoidance

### Phase 2 (drone)
- 2D LiDAR for horizontal obstacles
- VL53L1X rangefinders for vertical (rack tops, ceiling, ground)
- PX4 obstacle-avoidance modes for emergency stop
- Geofence derived from SLAM map prevents approach to walls
- No vision-based obstacle detection in Phase 2 (added Phase 2.5+ if needed)

### Phase 3+ (production)
- Add depth camera (Intel RealSense or Oak-D) for richer obstacle detection
- Multi-drone coordination via cloud-coordinated airspace

---

## 15. Known Technical Risks & Pitfalls

### SLAM in warehouses
- Feature-sparse symmetric racking → loop closure failures
- May require migration from slam-toolbox to **FAST-LIO2** if 2D SLAM degrades
- Dynamic objects (forklifts, workers, pallets being moved) appear as permanent map features → need filtering

### Cold storage hardware (Phase 2.5)
- Sub-zero temps kill unprotected electronics — design thermal enclosures
- Battery loses 20-40% capacity sub-zero — heating element required
- Condensation when moving between temp zones — IP-rated seals required

### Indoor flight (Phase 2)
- No GPS, so EKF tuning is delicate — PX4Flow + rangefinder fusion has known failure modes in low-feature environments (white walls, polished floors)
- FAA airspace near open dock doors → regulated airspace, drone must geofence away
- Battery flight time vs payload (LiDAR + RFID + camera) tradeoff is tight

### Solo-founder bandwidth
- Hemal has full-time Workday job — bandwidth is real
- Conservative estimate: 10-20 hrs/week from Hemal during pre-Bay period
- Implication: Phase 1 software scope must fit that budget. Don't over-promise to investors that we'll have a polished dashboard before Bay reunion.

### Dual-market focus dilution
- Cold chain + general storage simultaneously is a real risk for a 2-person team
- Mitigation: sequence, don't parallelize. General storage executes first; cold chain narrative persists in pitch materials. See Section 8.

---

## 16. Funding & Grant Applications

### Active applications

| Grant | Amount | Status | Owner | Notes |
|---|---|---|---|---|
| $250 Maker Grant | $250 | Applied | Hemal | Covers ~Tier 1 of Phase 1 BOM |
| Awesome Foundation | $1,000 | Applied | Jashwanth | Covers Tier 2-4 of BOM |
| gradCapital | $40K + 4% equity + $5K Atomic Fellowship | Video step pending | Jashwanth | Personal story, not product pitch. 2-3 min. Due in 4 days. |

### gradCapital is credible
- Zepto was first cohort
- $6M fund
- Lightspeed-backed portfolio companies
- Indian-origin founder advantage for Jashwanth's profile

### gradCapital video script (drafted)
Full personal-story script written, ~2:45 target length. Five-beat structure:
1. India birth, US move at 5, immigrant kid pattern-matching everything
2. Analog guitar auto-tuner — defining moment, 2am oscilloscope, "this is my life"
3. Pipelined RISC-V CPU + FPGA computer vision — chasing the same feeling at college
4. Eco Illini + Illini EV Concept PCB leadership — designing for teammates, not just self
5. TAIR is the natural extension — hardware that touches the physical world

Notes for delivery:
- Script does not mention Hemal by name (uses "we" instead)
- Script does not list specific stats or feature dump
- Slow down on the auto-tuner moment — that's the heart
- 3-5 takes; aim for take 3 to feel natural
- Eye contact with lens, not screen

### Future grants to consider
- **HAX** (early hardware accelerator)
- **Bolt.io** (hardware investment fund, no formal app, cold email)
- **SBIR Phase I** ($50-275K, application takes weeks, do once Phase 1 demo exists)

### What we're NOT doing
- Not raising a seed round yet — too early, would dilute too cheap
- Not on YC's radar yet — fall 2026 application is the target, with a Phase 1 demo video as primary asset

---

## 17. Jashwanth's Background

### The throughline
"I like building things that touch the physical world. Software that moves atoms."

### Defining hardware projects

**Analog guitar auto-tuner**
- Built fully analog — no microcontroller, no code
- Op-amp gyrators, bandpass filters, comparators
- 2 Hz tuning accuracy
- Months of debugging filter responses on oscilloscope
- The project that "made him fall in love with hardware"

**Pipelined RISC-V CPU**
- Designed every stage, hazard, bypass from scratch
- 3.8x throughput improvement over textbook reference design

**FPGA computer vision pipeline**
- 99% compute reduction vs same workload on general-purpose CPU

### Leadership roles
- **Eco Illini** — leads PCB design (UIUC fuel-efficient vehicle team)
- **Illini EV Concept** — leads PCB design (UIUC electric vehicle team)

Both involve handing boards to teammates who'll use them in real competitions — design-for-others is internalized.

### Personal context
- Born in India, moved to US at age 5
- ECE @ UIUC, GPA 3.84
- Frames self as hardware-first builder, not founder-by-default

---

## 18. Brand & Web Presence

### Domain
- **Primary:** `tairsystems.com`
- Registered (registrar TBD — Cloudflare Registrar recommended for wholesale pricing, free WHOIS privacy, no upsells)
- Defensive registrations to consider: `tair.tech`, `tairai.com`, `tairrobotics.com`, `gettair.com` (~$50/yr total)
- Email contact: `321tair@gmail.com` (placeholder; replace with `hello@tairsystems.com` once email hosting is set up)

### Visual identity

**Logo:** Serpentine drone-path mark, single continuous line forming a precise serpentine sweep pattern (drone scanning warehouse aisles row by row). Starting dot at top-left (origin). Directional arrow at bottom-right (end of scan, pointing right). Cyan `#00D4FF` on near-black `#0A0A0B`. Vector SVG at `/public/logo.svg` in the website repo.

**Why this logo:** It tells the entire TAIR story in one image — a path with clear start and end, exactly like a drone systematically scanning warehouse aisles. Distinctive in the warehouse-robotics space (no competitor uses serpentine path imagery). Functions as both logo and literal product diagram. Verified clear of conflict against major industry players (Gather AI, Corvus, Verity, Dexory, etc.) and broader tech logos.

**Color palette:**
- Background canvas: `#0A0A0B`
- Elevated surfaces: `#111114`
- Primary text: `#EDEDED`
- Secondary text: `#9A9A9F`
- Muted text: `#52525A`
- Accent (single, used sparingly): `#00D4FF`
- Subtle dividers: `#1F1F23`
- Elevated borders: `#2A2A2F`

**Typography:**
- Headings/body: **Geist Sans** (weights 400, 500, 600, 700)
- Technical/data: **Geist Mono**
- Both fonts loaded via `next/font/google` in Next.js

### Marketing site

**Location:** `C:\Users\jassu\UIUC\Projects\TAIR\website` (Windows, local dev)
**Repo:** intended to be added to GitHub TAIR org

**Stack:**
- Next.js 14 (App Router) + TypeScript
- Tailwind CSS
- Framer Motion for UI animations
- Lucide React for icons
- Three.js + @react-three/fiber + @react-three/drei for 3D scenes
- @react-three/postprocessing for cinematic effects (bloom, vignette, chromatic aberration)
- `lenis` (NOT `@studio-freight/lenis` — that name is deprecated) for smooth scroll
- gsap + @gsap/react for scroll-tied camera animations and SVG path drawing
- leva for dev-only debug panel
- react-intersection-observer for viewport triggers
- tunnel-rat for canvas-to-DOM portals

**Site sections** (single-page):
1. Navigation (TAIR logo + serpentine mark, links: How it works, Platform, Team, Contact, "Request demo" CTA)
2. Hero ("Inventory that knows itself" + animated terminal line + drone-scan 3D scene)
3. Problem (animated stats: 68%, $1.1T, $2M)
4. How it works (4 steps: Scan, Map, Reconcile, Correct)
5. Platform (live digital twin Three.js demo with terminal log + interactive "Run a scan" button)
6. Why TAIR (3 differentiators: lights-out autonomy, RFID through packaging, WMS-native integration)
7. Built by engineers (Jashwanth filled in, second founder card as "TBA")
8. Talk to us (contact form, mailto:321tair@gmail.com on submit)
9. Footer (logo, link columns, build identifier)

**Aesthetic reference:** Anduril + Linear + Vercel. Industrial, restrained, technical, cinematic. Dark mode only.

**Status (as of May 8, 2026):** First-pass site generated via Antigravity (Claude Opus 4.6 Thinking). Looks production-quality. Cinematic 3D upgrade prompt drafted — pending execution. Known recovery needed: Windows project state corrupted by `npm audit fix --force` which downgraded Next.js to 9.3.3 — recovery instructions exist.

### Operating rules learned
- **Never run `npm audit fix --force` on a Next.js project.** It downgrades Next aggressively to satisfy advisory database, breaking everything.
- The 80+ vulnerability warnings npm shows are almost all in transitive dev dependencies, not exploitable in production. Ignore them.
- Use `lenis` not `@studio-freight/lenis` (renamed package).
- Always commit to Git before installing new dependencies. Recovery from corrupted state without Git is painful.

### Antigravity prompts (saved as artifacts)
1. **Initial site build** — full prompt with aesthetic direction, tech stack, site structure, what-not-to-do guardrails
2. **Cinematic upgrade** — 7 upgrades: Lenis smooth scroll, hero scene, scroll-tied camera, interactive "Run a scan", animated stats, magnetic CTAs, page-load reveal
3. **Logo generation prompt** — 8 concepts for image-gen tools, with rebuild-in-Figma workflow

---

## 19. Key Decisions Log

| Date | Decision | Rationale |
|---|---|---|
| May 2026 | Andrew off the team | Personal departure; team is now 2 founders |
| May 2026 | RFID deferred to Phase 2 | SLAM is the hard, valuable Phase 1 demo. RFID is a known commodity. Saves $50-260 + a week of debug. Cleaner narrative: "Phase 1 proves mapping; Phase 2 adds identification" |
| May 2026 | Skip M6E Nano | Discontinued by SparkFun. Replace with YRM100 ($50-90) for Phase 2 |
| May 2026 | Logo = serpentine drone-path | Tells the product story visually. Distinctive in the warehouse-robotics space. Image 2 from initial concept set |
| May 2026 | Domain = tairsystems.com | `tair.ai` priced as premium ($500+). Tairsystems.com is professional B2B, $12/yr, available |
| May 2026 | Dual-track GTM (cold chain pitch / general storage execution) | Pure cold-chain wedge had a soft execution story for a 2-founder team without thermal hardware. Dual-track captures the sharp pitch + faster pilot path |
| May 2026 | Mac/Linux > Windows for dev | ROS2 native. ARM64 Mac matches Rubik Pi architecture. Windows-on-WSL2 has DDS multicast + USB passthrough issues. Use Windows only via VS Code Remote SSH |
| May 2026 | Push-cart Phase 1 (no motors) | Phase 1 is "sensor sled," not autonomous robot. Adding drive trains adds 2 weeks for zero demo value |
| May 2026 | First WMS = Extensiv | Mid-market 3PL favorite, documented REST API, lower friction than SAP EWM |
| May 2026 | Antigravity for website | Multi-file project mode + Claude Opus 4.6 (Thinking) produces production-quality output |
| May 2026 | gradCapital video = personal story | They explicitly asked for "what shaped you" not feature list. Hardware origin story (auto-tuner → CPU → FPGA → TAIR) |
| May 2026 | No mention of Hemal in gradCapital video | Video is *Jashwanth's* story. Use "we" without naming the team |

---

## 20. Pitch Materials

### One-line pitch
> Warehouses run on inventory data that's wrong a third of the time. TAIR fixes that overnight, autonomously, with zero workflow changes. Starting at $3,500/month.

### One-paragraph pitch
> The warehouse industry runs on broken data — average inventory accuracy is just 68%, costing the global economy $1.1 trillion a year. TAIR is an autonomous indoor intelligence platform: a nightly drone scan combines LiDAR, RFID, and barcode reads with an ML reconciliation engine, then pushes corrected inventory back to the customer's WMS before the morning shift. We start in cold chain pharma — where FDA compliance is a forcing function and our RFID-through-condensation advantage matters most — and expand into the broader $1.1T market through mid-market 3PLs.

### Statistics for pitches
- **68%** — industry average inventory accuracy
- **$1.1T** — annual global cost of inventory inaccuracy
- **$685K – $1.52M** — annual value of 1% accuracy improvement for mid-size operation
- **$500K – $2M** — annual cycle count labor cost per large facility
- **$3,500 – $20,000+/mo** — TAIR pricing range
- **~71%** — target gross margin
- **150K+** — US warehouses (TAM scale)

### Why now
- Cold chain temperature compliance + FDA DSCSA = forcing function for pharma (regulatory deadline pressure)
- WMS-platform consolidation + API maturity makes integration cheap
- Drone hardware costs collapsed 10x in last 5 years
- LLM-era ML reconciliation is genuinely better than rule-based engines
- Labor shortage in warehouse cycle counting is structural, not cyclical

### Why TAIR (not the incumbents)
1. **Lights-out autonomous** — no human-per-aisle (vs Gather AI)
2. **RFID through packaging** — wins where camera-only systems fail
3. **Cold-chain niche** — FDA compliance + thermal-rated hardware is a defensible wedge
4. **Mid-market accessible** — $3,500/mo Starter opens a market enterprise-priced incumbents can't reach profitably
5. **Integration speed** — small team, fast install, documented Extensiv API

### Why us
- Hardware engineering depth (Jashwanth: analog circuits, RISC-V CPU, FPGA CV, two PCB leadership roles)
- Software engineering depth (Hemal: full-stack, ROS2, ML, cloud)
- Both technical, both shipping, no growth-hire dilution at pre-seed
- Two-person team can iterate faster than $74M-funded incumbents on a single vertical

---

## How to Use This Document

**For a new chat:** Drop this entire markdown file in. Tell the AI: "I'm working on TAIR. Here's the full context. I want to work on [X]." The AI now has everything.

**For investor / grant updates:** Sections 1, 3, 4, 7, 8, 9, 16, 19, 20 are the pitch-relevant sections.

**For technical discussions:** Sections 5, 6, 10, 11, 12, 13, 14, 15.

**For team coordination:** Sections 2, 13.

**For brand / website work:** Section 18.

**Update this doc when:**
- A team change happens
- A hardware decision is made
- A grant or funding event occurs
- A go/no-go strategic call is made
- The end of any meaningful chat session — the chat history is ephemeral, this doc is the persistent memory

**End-of-chat update protocol:** When Jashwanth says "end this chat" or "update the handoff doc," produce an updated version of this file with everything covered in the session folded in, then present it for download.
