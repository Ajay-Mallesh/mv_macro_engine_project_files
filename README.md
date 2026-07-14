# Multi-Voltage Macro Engine (MV_MACRO_ENGINE) 🚀
**32nm Multi-Voltage ASIC Physical Design Reference (RTL to GDSII)**

Welcome to the `mv_macro_engine` repository. This project demonstrates a complete, production-grade Physical Design (PD) implementation of a high-performance, dual-supply (0.95V / 0.75V) macro core using Synopsys EDA tools (Design Compiler, ICC2, PrimeTime, StarRC).

---

## 📌 Project Information
* **Author:** Ajay Mallesh
* **Project Contributors:** Aviraj Dhale | Selva Prakash | Venkatesh Vattem | Praveen
* **Reviewers:** Gemini Pro 3.1 & Ajay Mallesh
* **Version:** 2.0.0
* **Date:** 14/07/2026
* **Contact:** ajaynew96326@gmail.com | [LinkedIn](https://www.linkedin.com/in/ajaymallesh)

---

## 🏗️ Architecture Overview
The `mv_macro_engine` is engineered to optimize power efficiency and meet strict SoC thermal constraints through aggressive voltage scaling. The architecture is partitioned into two UPF-driven domains:

1. **High-Performance Domain (`PD_TOP` / 0.95V):** Houses the primary computational engine, high-speed I/O interfaces, and top-level state machines.
2. **Low-Power Domain (`PD_LP` / 0.75V):** Incorporates the heavy, latency-tolerant computation and 16 `lp_ram_subsystem` SRAM hard macros to minimize dynamic switching power and static leakage.

### Technology Specifications
| Parameter | Specification |
| :--- | :--- |
| **Technology Node** | 32nm CMOS (SAED32) |
| **Design Type** | Multi-Voltage ASIC |
| **Instance Count** | ~76,000 Standard Cells |
| **Macro Count** | 100 Hard Macros (16 SRAMs + 84 Default) |
| **Voltage Domains** | 0.95V (VDD_DEFAULT) / 0.75V (VDD_LP) |
| **Timing Methodology** | MCMM (Multi-Corner Multi-Mode) |
| **Clock Topology** | H-Tree + NDR (Double Spacing) |
| **Signoff Standards** | PrimeTime (STA) / StarRC (SPEF 3D Extraction) |

---

## 📂 Repository Structure
```text
mv_macro_engine/
├── inputs/                  # RTL Verilog, .sdc constraints, .upf power intent
├── outputs/                 # Intermediate netlists, DEF, and final GDSII
├── scripts/                 # Automated TCL execution scripts
│   ├── Synthesis/
│   ├── Floorplan_to_Powerplan/
│   ├── Placement/
│   ├── CTS_H_TREE/
│   ├── Routing/
│   └── Signoff/
├── STARRC/                  # Parasitic extraction run directory & outputs
├── PRIMETIME/               # STA sessions, DMSA master scripts, and ECO files
├── docs/                    # Constraints, port locations, and design manuals
└── README.md
