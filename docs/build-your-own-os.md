# Build Your Own OS — study track

Same shape as the Lisp track: staged, each stage ends with something that boots.
The hard part of OS work is not concepts, it's the *feedback loop* — get QEMU +
GDB + a cross-compiler working on day one and everything after is tractable.

---

## Stage 0 — Theory you need before the metal

You don't need all of this first, but you'll be lost without some of it.

| Resource | Notes |
|---|---|
| **Operating Systems: Three Easy Pieces** (Arpaci-Dusseau) — free: <https://pages.cs.wisc.edu/~remzi/OSTEP/> | The best OS textbook, and it's free. Three parts: virtualization (CPU + memory), concurrency, persistence. Read virtualization before you touch paging code. |
| **Computer Systems: A Programmer's Perspective** (Bryant & O'Hallaron) | Linking, loading, the memory hierarchy, the machine-level view. Fills the gap between "I know C" and "I know what C compiles into". |
| **nand2tetris** — <https://www.nand2tetris.org/> | Optional but excellent if the hardware layer feels like magic. Free course, builds a CPU from gates up. |
| **Operating System Concepts** (Silberschatz) / **Modern Operating Systems** (Tanenbaum) | Classic references. Use as lookup, not cover-to-cover. |

---

## Stage 1 — Boot something

Goal: your own code printing to the screen on bare metal (in QEMU).

- **OSDev Wiki** — <https://wiki.osdev.org/> — the community reference. Start with:
  - *Getting Started* → *Required Knowledge* → **GCC Cross-Compiler**
    (<https://wiki.osdev.org/GCC_Cross-Compiler>) — do this properly, host
    toolchains will bite you.
  - **Bare Bones** (<https://wiki.osdev.org/Bare_Bones>) — multiboot header,
    linker script, `kernel_main`, VGA text output.
  - **Meaty Skeleton** (<https://wiki.osdev.org/Meaty_Skeleton>) — turn it into
    a real source tree with a libc.
- **The little book about OS development** — <https://littleosbook.org/> — Helin
  & Renberg. ~80 pages, x86, GRUB, segmentation, interrupts, paging, user mode.
  The single best "first 3 months" document.
- **Writing a Simple Operating System from Scratch** (Nick Blundell) —
  <https://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf> —
  starts at the boot sector in raw assembly. Read it if the 512-byte
  boot sector still feels like a black box.

**Milestone:** `make run` boots your kernel in QEMU and prints a string. Commit
this. It's the moment the project becomes real.

---

## Stage 2 — The core four

In order, because each depends on the last:

1. **Interrupts / IDT** — keyboard input and a timer tick.
2. **Physical + virtual memory** — a frame allocator, then page tables, then a
   kernel heap (`kmalloc`).
3. **Multitasking** — context switch, scheduler (round-robin first), then
   processes with separate address spaces.
4. **User mode + syscalls** — ring 3, the syscall gate, and the first `write()`.

Guided paths through exactly this sequence:

- **Writing an OS in Rust** (Philipp Oppermann) — <https://os.phil-opp.com/> —
  the best-maintained modern tutorial series, in any language. Even if you write
  C or Zig, read it: the explanations of paging and async are excellent.
- **Operating Systems: From 0 to 1** (Tu Do Hoang) — <https://github.com/tuhdo/os01> —
  free book, very deep on toolchain/ELF/linker internals that other guides skip.
- **BrokenThorn OS Development Series** — <http://www.brokenthorn.com/Resources/OSDev1.html> —
  older, x86 real-mode heavy, but thorough on the boot path.
- **Rust Raspberry Pi OS tutorials** (Andre Richter) —
  <https://github.com/rust-embedded/rust-raspberrypi-OS-tutorials> — if you'd
  rather target AArch64 real hardware than x86 in an emulator. Excellent
  incremental structure.

**Milestone:** two user-mode processes preempted by a timer interrupt, both
calling into your kernel.

---

## Stage 3 — Read a whole OS

- **xv6** (MIT 6.1810/6.828) — <https://pdos.csail.mit.edu/6.828/> — a complete
  Unix-like kernel in ~9000 lines of readable C, *with an accompanying book*
  that walks through the source line by line. Course labs and lecture notes are
  public. **If you do only one thing in this track, do xv6.** RISC-V version is
  current; the x86 version is still around and fine.
- **MINIX / Operating Systems: Design and Implementation** (Tanenbaum &
  Woodhull) — the microkernel counterpoint to xv6's monolith.
- **Project Oberon** (Wirth & Gutknecht) — <https://www.projectoberon.net/> —
  free PDFs of *the entire book*: a language, its compiler, and a complete
  graphical OS, all fully described, all fitting in one person's head. The best
  demonstration that both halves of what you're studying are one project.
- **SerenityOS** — <https://serenityos.org/> — a modern from-scratch Unix with
  a GUI and a browser. Andreas Kling's "OS hacking" videos
  (<https://www.youtube.com/@awesomekling>) are the best available footage of
  what real kernel debugging actually looks like.

---

## Stage 4 — Going further

- **Linux internals:** *Linux Kernel Development* (Robert Love) for the tour,
  *Understanding the Linux Kernel* (Bovet & Cesati) for depth, and
  <https://www.kernel.org/doc/html/latest/> for truth. Then
  <https://kernelnewbies.org/FirstKernelPatch>.
- **Linux From Scratch** — <https://www.linuxfromscratch.org/> — not kernel
  work, but it teaches what a *system* is above the kernel: init, libc,
  toolchain, userland.
- **Filesystems:** implement FAT12 (trivial, well documented) → ext2
  (<https://www.nongnu.org/ext2-doc/ext2.html>) → then read about journaling.
- **Drivers:** PS/2 keyboard → PIT/APIC timer → ATA PIO disk → VGA/framebuffer →
  PCI enumeration → e1000 NIC. Roughly increasing order of pain.
- **Specs you'll actually open:** Intel SDM Vol. 3 (system programming),
  the ACPI spec, the multiboot2 spec, UEFI spec if you skip legacy BIOS.

---

## Toolchain — set this up first, not later

- **QEMU** with `-s -S` plus GDB (`target remote :1234`) — non-negotiable.
- **A cross-compiler** (`i686-elf-gcc` or `x86_64-elf-gcc`), built per the OSDev
  wiki. Or **Zig**, which cross-compiles freestanding targets with no toolchain
  build at all (`-target x86_64-freestanding-none`) — relevant given `zig/` in
  this repo; see <https://ziglang.org/documentation/master/#Freestanding> and the
  `pluto` (<https://github.com/ZystemOS/pluto>) and `zen`
  (<https://github.com/AndreaOrru/zen>) kernels as worked examples.
- **A bootloader**: GRUB2 (multiboot2) to start; **Limine**
  (<https://github.com/limine-bootloader/limine>) is the modern, much nicer
  option and handles UEFI for you.
- **Bochs** as a second emulator — its internal debugger catches triple faults
  that QEMU makes opaque.

---

## Where the two tracks meet — Lisp operating systems

Since you're studying both, this is the crossover reading:

- **Mezzano** — <https://github.com/froggey/Mezzano> — a working operating
  system written in Common Lisp, with a GUI. Boots on real hardware and in QEMU.
- **Loko Scheme** — <https://scheme.fail/> — R6RS Scheme that runs on bare metal
  and on Linux without a libc. Very readable, actively documented.
- **MIT CADR / Symbolics Genera** — the Lisp machine lineage. Start with
  *The Lisp Machine Manual* (<https://bitsavers.org/pdf/mit/cadr/>) and the
  Bitsavers scans; then Richard Gabriel's *Lisp: Good News, Bad News, How to
  Win Big* for why the model lost.
- **Movitz** (<https://github.com/frodef/movitz>) and **Interim OS**
  (<https://github.com/m
