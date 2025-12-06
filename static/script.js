document.addEventListener("DOMContentLoaded", () => {
    // Cek apakah plugin sudah termuat dari CDN
    if (typeof gsap !== "undefined") {
        // Register plugin (ScrollTrigger, SplitText, CustomEase sudah jadi variabel global)
        // Kita pakai try-catch biar kalau SplitText error (karena link mati), sisa web tetap jalan
        try {
            gsap.registerPlugin(ScrollTrigger, SplitText, CustomEase);
        } catch (e) {
            console.warn("Ada plugin yang gagal diload (mungkin SplitText?):", e);
        }

        CustomEase.create("hop", ".8, 0, .3, 1");

        // ScrollTo top on refresh
        if ('scrollRestoration' in history) {
            history.scrollRestoration = 'manual';
        }
        window.scrollTo(0, 0);
        ScrollTrigger.refresh();

        const splitTextElements = (
            selector,
            type = "words,chars",
            addFirstChar = false
        ) => {
            const elements = document.querySelectorAll(selector);
            elements.forEach((element) => {
                // Cek apakah SplitText tersedia sebelum dipakai
                if (typeof SplitText !== "undefined") {
                    const splitText = new SplitText(element, {
                        type,
                        wordsClass: "word",
                        charsClass: "char",
                    });

                    if (type.includes("chars")) {
                        splitText.chars.forEach((char, index) => {
                            const originalText = char.textContent;
                            char.innerHTML = `<span>${originalText}</span>`;

                            if (addFirstChar && index === 0) {
                                char.classList.add("first-char");
                            }
                        });
                    }
                } else {
                    console.error("SplitText plugin tidak ditemukan/gagal di-load.");
                }
            });
        };

        // --- Initialize SplitText ---
        splitTextElements(".intro-title h1", "words, chars", true);
        splitTextElements(".outro-title h1");
        splitTextElements(".tag p", "words");
        splitTextElements(".card h1", "words, chars", true);
        splitTextElements(".hero-title h1", "words, chars");

        const isMobile = window.innerWidth <= 1000;

        // --- GSAP Set Initial States ---
        gsap.set(
            [
                ".split-overlay .intro-title .first-char span",
                ".split-overlay .outro-title .char span",
            ],
            { y: "0%" }
        );

        gsap.set(".split-overlay .intro-title .first-char", {
            x: isMobile ? "7.5rem" : "18rem",
            y: isMobile ? "-1rem" : "-2.75rem",
            fontWeight: "900",
            scale: 0.75,
        });

        gsap.set(".split-overlay .outro-title .char", {
            x: isMobile ? "-3rem" : "-8rem",
            fontSize: isMobile ? "6rem" : "14rem",
            fontWeight: "500",
        });

        // --- Timeline Animation ---
        const tl = gsap.timeline({ defaults: { ease: "hop" } });
        const tags = gsap.utils.toArray(".tag");

        tags.forEach((tag, index) => {
            tl.to(
                tag.querySelectorAll("p .word"),
                { y: "0%", duration: 0.75 },
                0.5 + index * 0.1
            );
        });

        tl.to(".preloader .intro-title .char span", { y: "0%", duration: 0.75, stagger: 0.05 }, 0.5)
            .to(".preloader .intro-title .char:not(.first-char) span", { y: "100%", duration: 0.75, stagger: 0.05 }, 2)
            .to(".preloader .outro-title .char span", { y: "0%", duration: 0.75, stagger: 0.075 }, 2.5)
            .to(".preloader .intro-title .first-char", { x: isMobile ? "8rem" : "20rem", duration: 1 }, 3.5)
            .to(".preloader .outro-title .char", { x: isMobile ? "-3rem" : "-8rem", duration: 1 }, 3.5)
            .to(".preloader .intro-title .first-char", {
                x: isMobile ? "7.5rem" : "18rem",
                y: isMobile ? "-1rem" : "-3rem",
                fontWeight: "900",
                scale: 0.75,
                duration: 0.75
            }, 4.5)
            .to(".preloader .outro-title .char", {
                x: isMobile ? "-3rem" : "-8rem",
                fontSize: isMobile ? "6rem" : "14rem",
                fontWeight: "500",
                duration: 0.75,
                onComplete: () => {
                    gsap.set(".preloader", { clipPath: "polygon(0 0, 100% 0, 100% 50%, 0 50%)" });
                    gsap.set(".split-overlay", { clipPath: "polygon(0 50%, 100% 50%, 100% 100%, 0 100%)" });
                }
            }, 4.5)
            .to(".container", { clipPath: "polygon(0% 48%, 100% 48%, 100% 52%, 0% 52%)", duration: 1 }, 5);

        tags.forEach((tag, index) => {
            tl.to(tag.querySelectorAll("p .word"), { y: "100%", duration: 0.75 }, 5.5 + index * 0.1);
        });

        tl.to([".preloader", ".split-overlay"], { y: (i) => (i === 0 ? "-50%" : "50%"), duration: 1 }, 6)
            .to(".container", {
                clipPath: "polygon(0% 0%, 100% 0%, 100% 100%, 0% 100%)",
                duration: 1,
                onComplete: () => {
                    document.body.classList.remove("no-scroll");
                }
            }, 6)
            .to(".container .card", { clipPath: "polygon(0% 0%, 100% 0%, 100% 100%, 0% 100%)", duration: 0.75 }, 6.25)
            .to(".container .card h1 .char span", { y: "0%", duration: 0.75, stagger: 0.05 }, 6.5)
            .to(".hero .hero-title .char span", { y: "0%", duration: 0.75, stagger: 0.05 }, 6.5)
            .to(".container .subtitle", { opacity: 0.7, duration: 0.5 }, 7)
            .to(".tags-overlay", { display: "none" }, 7.2);

        // --- About Section Animation ---
        splitTextElements(".about-content p", "words");
        document.querySelectorAll(".about-content p").forEach((el) => {
            const words = el.querySelectorAll(".word");
            gsap.set(words, { opacity: 0.1 });
            gsap.to(words, {
                opacity: 1,
                stagger: 0.05,
                duration: 0.6,
                ease: "power2.out",
                scrollTrigger: {
                    trigger: el,
                    start: "top 50%",
                    end: "bottom 50%",
                    scrub: true,
                },
            });
        });

        // --- ScrollTrigger MatchMedia ---
        const details = gsap.utils.toArray(".desktopContentSection:not(:first-child)");
        const photos = gsap.utils.toArray(".desktopPhoto:not(:first-child)");
        gsap.set(photos, { yPercent: 101 });
        const allPhotos = gsap.utils.toArray(".desktopPhoto");

        let mm = gsap.matchMedia();

        mm.add("(min-width: 1000px)", () => {
            ScrollTrigger.create({
                trigger: ".how-to-use",
                start: "top top",
                end: "bottom bottom",
                pin: ".right",
            });

            details.forEach((detail, index) => {
                let headline = detail.querySelector("h1");
                let animation = gsap.timeline()
                    .to(photos[index], { yPercent: 0 })
                    .set(allPhotos[index], { autoAlpha: 0 });

                ScrollTrigger.create({
                    trigger: headline,
                    start: "top 80%",
                    end: "top 50%",
                    animation: animation,
                    scrub: true,
                    markers: false,
                });
            });
        });
    }
});