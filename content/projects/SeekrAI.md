+++
date = '2025-06-18T16:14-05:00'
draft = false
title = 'SeekrAI'
tags = ['ai','machine-learning','project','job-search']
description = 'AI-powered Job search and discovery tool'
type = 'post'
+++

# SeekrAI

SeekrAI is your over-caffeinated AI intern that munches through job postings—PDFs, CSVs, you name it—and spits out slick insights in real time. Powered by Flask, Redis, and the OpenAI API, all snug in Docker, it’s basically the job-hunting sidekick you never knew you needed. Deploy with a single docker run, sit back, and watch it do the heavy lifting. Hire smarter, not harder.

Check out the [repo](https://github.com/LordHerdier/SeekrAI) for more details.

**Why SeekrAI Exists**

You’ve scrolled through endless, copy-pasted job posts and still can’t tell if “ninja rockstar guru” is actually hiring or trolling you. SeekrAI slurps up all those postings, rips out the fluff, and serves you the juicy bits: skills, requirements, and insights, pronto.


**How It Rolls**

1. **Ingest Everything**: Drop in PDFs, CSVs, DOCXs—whatever. SeekrAI’s background workers snatch your files, toss them through an OpenAI-powered pipeline, and emerge with clean, structured job data.
2. **AI-Driven Analysis**: Behind the scenes, GPT-fun magic extracts required skills, experience levels, and even flags weird buzzword overload.
3. **Real-Time Feedback**: Hit the web UI or hit the API—status updates happen faster than you can refresh Twitter.
4. **Cache & Scale**: Redis caching keeps repeat analyses snappy, so you’re never waiting on déjà vu.

**Under the Hood**

* **Python 3.9+** with Flask (because microframeworks are ironically huge)
* **Redis** for caching (because nobody likes slow AI)
* **OpenAI API** doing the heavy lifting of natural-language wrangling
* **File-based storage** for simplicity, with Docker sealing the deal
* **Gunicorn** in production to pretend Flask can handle real traffic

**Quick-Start in Docker**

```bash
docker run -d \
  -p 5000:5000 \
  -e OPENAI_API_KEY=… \
  -e SECRET_KEY=… \
  --name seekrai \
  lordherdier/seekrai:latest
```

And voilà—your own personal job-post whisperer. Want to tweak settings? Drop in a `.env` and sail on. No multi-hour installs, no dependency nightmares—just plug in and play.

---

SeekrAI: because life’s too short to manually parse “preferred qualifications.”
