# Warsztat Współpracy — wdrożenie

✅ **Już wdrożone i przetestowane (2026-09-20):**
- Supabase: projekt "Marki999zzz's Project" (`zylxxtekqhulgbtmjnje`), schemat wgrany (łącznie z kolumnami timera), klucze uzupełnione w `index.html`.
- GitHub: repo [Marki999zzz/cross-functional-workshop](https://github.com/Marki999zzz/cross-functional-workshop) (publiczne), GitHub Pages włączone z brancha `main`.
- **Link dla uczestników:** https://marki999zzz.github.io/cross-functional-workshop/
- **Link dla moderatora (sufler + sterowanie):** https://marki999zzz.github.io/cross-functional-workshop/?mode=host (PIN: `1234`)
- **Link dla ekranu / rzutnika (same wyniki, bez sufleru):** https://marki999zzz.github.io/cross-functional-workshop/?mode=screen (ten sam PIN) — otwiera się też przyciskiem "📽️ Otwórz ekran" w panelu moderatora.
- Timer jest teraz **współdzielony przez Supabase** — Start/Pauza/Reset klikniete w panelu moderatora widać zsynchronizowane na ekranie projektora (i na każdym innym otwartym widoku) w czasie rzeczywistym.
- Sprawdzone end-to-end: zgłoszenie z linku uczestnika pojawia się natychmiast na ekranie moderatora i na ekranie projektora, przełączenie modułu i timer synchronizują się między urządzeniami. Dane testowe wyczyszczone.

**Aktualizacja (2026-09-20 wieczorem):**
- Wyniki analiz AI (grupowanie odpowiedzi, lista do głosowania) są teraz **zawsze po angielsku**, niezależnie od tego, w jakim języku uczestnik napisał odpowiedź i jaki język ma ustawiony interfejs.
- Dodano etap **„🚀 Start” (poczekalnia)** — domyślny stan przed rozpoczęciem warsztatu. Ekran projektora (`?mode=screen`) pokazuje wtedy duży kod QR + link do dołączenia zamiast treści modułu; panel moderatora pokazuje krótką notatkę. Po kliknięciu „1. Powitanie i Icebreaker” warsztat rusza normalnie. Uczestnik, który dołączy zanim moderator wystartuje, widzi komunikat oczekiwania zamiast pustego formularza.
- Nowe wdrożenia bazy (`schema.sql`) mają teraz domyślny `active_module = 'lobby'` zamiast `'welcome'`.

**Aktualizacja (2026-09-20, po symulacji z 6 uczestnikami):**
- **Naprawiono wyciek subskrypcji real-time.** Każde przełączenie modułu/analiza otwierało nowe połączenie nasłuchujące i nigdy go nie zamykało — po wielu operacjach w krótkim czasie panel moderatora przestawał odbierać aktualizacje na żywo. Teraz wszystkie subskrypcje są śledzone i zamykane przy każdym pełnym przeładowaniu widoku, a subskrypcje analizy AI nie są już odtwarzane przy każdej nowej odpowiedzi (tylko raz na moduł). Zweryfikowane: 5 kolejnych zgłoszeń nie zwiększa już liczby aktywnych połączeń.
- **Spójny język w podsumowaniu końcowym.** Checklista i zobowiązania uczestników (surowy tekst, nieprzetworzony przez AI) mogły zostać w języku, w jakim ktoś je napisał. Na ekranie "Podsumowanie" pojawia się teraz przycisk **"🌐 Przetłumacz na angielski"** (widoczny tylko dla moderatora) — jedno kliknięcie + wklejenie odpowiedzi Claude tłumaczy całą checklistę i zobowiązania naraz; wynik jest zapamiętany i widoczny też na ekranie projektora / dla uczestników.
- **Archiwizacja sesji.** Na ekranie "Podsumowanie" moderator ma przycisk **"📦 Zarchiwizuj i rozpocznij nową sesję"** — zapisuje skompilowany wynik (checklistę, 3 najlepsze pomysły, kartę współpracy, zobowiązania) do nowej tabeli `sessions`, a następnie czyści bieżącą sesję (jak "Nowa sesja (reset)"). Przycisk **"🗂 Archiwum"** w nagłówku panelu moderatora pokazuje listę wszystkich zarchiwizowanych warsztatów — klik w wpis pokazuje jego zapisany wynik (tylko do odczytu); "← Powrót do bieżącej sesji" wraca do aktywnego warsztatu.
- Schemat bazy rozszerzony o tabelę `sessions` (patrz `schema.sql`).
- Aktualny stan bazy: sesja czysta (poczekalnia), jeden przykładowy wpis w archiwum ("Testowa sesja — symulacja 6 osób") pozostawiony jako demonstracja funkcji — możesz go usunąć ręcznie w Supabase (tabela `sessions`), jeśli niepotrzebny.

**Aktualizacja (2026-09-20, eksport PDF):**
- Na ekranie "Podsumowanie" moderator ma teraz przycisk **"📄 Wygeneruj PDF (wszystkie odpowiedzi i wnioski)"** obok przycisku archiwizacji. Klik buduje pełny raport (surowe odpowiedzi wszystkich uczestników z każdego modułu z tagiem działu, wnioski/tematy AI tam, gdzie analiza została zapisana, wyniki głosowania z modułu 5, zatwierdzoną kartę współpracy z modułu 6, oraz skompilowane podsumowanie końcowe) i otwiera natywne okno drukowania przeglądarki — wystarczy wybrać "Zapisz jako PDF" jako drukarkę docelową.
- Raport używa dedykowanego, ukrytego kontenera i reguł `@media print`, które chowają resztę interfejsu na czas druku (bez zewnętrznych bibliotek PDF) — działa poprawnie z polskimi znakami diakrytycznymi.
- Nie wymaga zmian w schemacie bazy — funkcja tylko odczytuje istniejące dane z `responses`, `analysis`, `votes` i `session_state`.
- **Automatyczne generowanie:** gdy moderator wejdzie na ekran "Podsumowanie" (klik w moduł 8 albo automatyczne przejście), PDF generuje się i okno drukowania otwiera się samo — bez potrzeby klikania przycisku. Uruchamia się tylko raz przy wejściu na ten ekran (nie odpala się ponownie przy zmianie języka czy dopływie nowych danych); przycisk "📄 Wygeneruj PDF" zostaje, aby można było wygenerować raport ponownie w dowolnym momencie (np. po dodaniu tłumaczenia).

**Aktualizacja (2026-09-20, komentarze moderatora i edycja wniosków AI):**
- Przy każdym pytaniu (moduły 1–4, 7 oraz karta współpracy) moderator ma teraz pod wynikami analizy AI przycisk **"✏️ Edytuj wnioski"** — otwiera edytowalne pole z surowym JSON-em wygenerowanych tematów, które można ręcznie poprawić (np. zmienić nazwę tematu, priorytet, liczbę, przykłady) i zapisać.
- Pod tym polem znajduje się zawsze widoczne pole **"🗨️ Komentarz moderatora"** — dowolny tekst dodany przez moderatora do danego pytania, zapisywany osobno od wniosków AI (nie trzeba mieć wygenerowanej analizy AI, żeby dodać sam komentarz).
- Obie rzeczy — poprawione wnioski i komentarz moderatora — pojawiają się też w generowanym raporcie PDF, pod wnioskami AI dla danego pytania.
- Wymagało to nowej kolumny `comment` w tabeli `analysis` (już wgrane na żywej bazie Supabase oraz do `schema.sql`).

**Aktualizacja (2026-09-20, potwierdzenie wysłania odpowiedzi):**
- Po wysłaniu odpowiedzi przez uczestnika (moduły 1–4, 7) ekran pokazuje teraz trwały komunikat **"✅ Odpowiedź została wysłana"** zamiast czyścić formularz i pozwalać na ponowne wysłanie. Komunikat zostaje widoczny na urządzeniu uczestnika, dopóki moderator nie przejdzie do kolejnego etapu — nawet jeśli w międzyczasie coś innego odświeży ekran (np. start/pauza timera).
- Stan "wysłano odpowiedź dla modułu X" jest zapamiętywany lokalnie w przeglądarce uczestnika (localStorage), więc jeśli moderator wróci do wcześniejszego, już wypełnionego modułu, uczestnik nadal widzi potwierdzenie, a nie pusty formularz.
- Nie dotyczy głosowania (moduł 5) — tam uczestnik może zmienić swój głos, więc formularz głosowania pozostaje edytowalny jak dotychczas.

**Ważne przy edycji `index.html` w przyszłości:** edytor tekstowy GitHuba (CodeMirror) w tej sesji nie reagował na skróty klawiszowe (Ctrl+A itp.) wysyłane przez automatyzację przeglądarki — do aktualizacji pliku zadziałało wgranie przez `github.com/<repo>/upload/main` (drag&drop / wybór pliku), a nie edycja w przeglądarkowym edytorze.

Poniższa instrukcja zostaje jako odniesienie, gdyby trzeba było powtórzyć wdrożenie (np. nowe repo, inny projekt Supabase).

Trzy pliki w tym folderze:
- `index.html` — cała aplikacja (widok uczestnika i widok moderatora w jednym pliku)
- `schema.sql` — schemat bazy danych do wklejenia w Supabase
- `DEPLOY.md` — ta instrukcja

Uczestnicy **nie potrzebują żadnego konta** (ani Claude, ani Supabase, ani GitHub). Jedyną osobą z kontami jesteś Ty (moderator).

## 1. Supabase — baza danych (5 minut)

1. Zaloguj się na [supabase.com](https://supabase.com) → otwórz swój projekt (albo załóż nowy, darmowy plan wystarczy).
2. W menu po lewej: **SQL Editor** → **New query**.
3. Skopiuj całą zawartość pliku `schema.sql` z tego folderu, wklej i kliknij **Run**.
   - Tworzy 4 tabele (`session_state`, `responses`, `votes`, `analysis`), włącza dostęp bez logowania (RLS) i replikację na żywo.
4. W menu: **Project Settings → API**. Skopiuj:
   - **Project URL** (np. `https://xxxxxxxx.supabase.co`)
   - klucz **`anon` `public`** (NIE `service_role` — ten musi zostać sekretny)

## 2. Uzupełnij `index.html`

Otwórz `index.html` w edytorze tekstu, znajdź na górze sekcji `<script>`:

```js
const SUPABASE_URL = "TWOJ_SUPABASE_URL";
const SUPABASE_ANON_KEY = "TWOJ_SUPABASE_ANON_KEY";
const HOST_PIN = "1234";
```

Wklej swoje wartości z kroku 1. Zmień też `HOST_PIN` na własny numer (to tylko prosta blokada w interfejsie, chroni przed przypadkowym wejściem uczestnika w panel moderatora — nie jest to prawdziwe zabezpieczenie na poziomie bazy danych).

## 3. Wdrożenie na GitHub Pages

1. Utwórz nowe repozytorium na GitHub (może być publiczne — `anon key` jest z założenia bezpieczny do publikacji, chroniony regułami w bazie).
2. Wgraj do niego `index.html` (drag & drop w interfejsie GitHub, albo `git push`).
3. W repozytorium: **Settings → Pages** → w "Source" wybierz branch `main` i folder `/ (root)` → **Save**.
4. Po chwili GitHub poda adres, np. `https://twoj-login.github.io/nazwa-repo/`.

## 4. Linki na warsztat

- **Uczestnicy** (telefon/laptop): `https://twoj-login.github.io/nazwa-repo/`
- **Ty / ekran projektora**: `https://twoj-login.github.io/nazwa-repo/?mode=host` — poprosi o PIN przy pierwszym wejściu na urządzeniu.

Rozdaj uczestnikom pierwszy link (najlepiej jako QR kod — wygenerujesz go za darmo w dowolnym generatorze QR, wklejając ten adres).

## 5. Grupowanie odpowiedzi przez AI (most ręczny)

Ponieważ narzędzie nie ma własnego klucza API, analiza AI działa przez Ciebie:

1. Na ekranie moderatora kliknij **„✨ Analizuj i pogrupuj (AI)"** przy dowolnym polu z odpowiedziami.
2. Pojawi się gotowy tekst (prompt) — kliknij **„Kopiuj prompt"**.
3. Wklej go w rozmowie z Claude (np. w tej samej rozmowie w Claude Code, w której powstało to narzędzie, albo na claude.ai).
4. Skopiuj odpowiedź Claude (sam JSON) i wklej ją w polu **„Wklej tutaj odpowiedź Claude"**.
5. Kliknij **„Zapisz wynik"** — pogrupowane tematy z priorytetami pojawią się od razu na ekranie (u wszystkich, na żywo).

Ten sam mechanizm obsługuje generowanie listy do głosowania (moduł 5) i kandydujących zasad karty współpracy (moduł 6).

## 6. Reset przed kolejnym warsztatem

Przycisk **„Nowa sesja (reset)"** w panelu moderatora czyści wszystkie odpowiedzi, głosy i analizy — użyj przed powtórnym uruchomieniem warsztatu z inną grupą.

## Ograniczenia do świadomości

- **PIN moderatora to zabezpieczenie tylko w interfejsie**, nie na poziomie bazy danych — każdy, kto zna adres API Supabase i klucz `anon`, technicznie mógłby zapisać dowolne dane. Akceptowalne dla jednorazowego, wewnętrznego warsztatu; nieodpowiednie dla poufnych danych.
- Timer w panelu moderatora resetuje się przy odświeżeniu strony (nie jest zapisywany w bazie) — to świadome uproszczenie.
- Jeśli chcesz w przyszłości pełnej automatyzacji AI (bez ręcznego kopiowania), doda się Supabase Edge Function z kluczem API (Anthropic lub OpenAI) — wtedy przycisk "Analizuj" zadziała od razu, bez kroku 5 powyżej.
