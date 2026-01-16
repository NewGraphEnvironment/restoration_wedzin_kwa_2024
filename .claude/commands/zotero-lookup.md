Look up a reference in the local Zotero database by citation key.

## Usage
Provide a citation key (e.g., `environmentcanada2012Canadianaquatic`) or partial search term.

## Steps

### 0. Context Checkpoint (BEFORE heavy operations)
Before reading any PDF attachments, ask the user:
> "Before I read the PDF, should we commit any pending changes or update planning files? This prevents losing work if we run low on context space."

If user says yes:
- Commit pending changes with descriptive message
- Update task_plan.md, findings.md, progress.md as needed
- Then proceed to PDF reading

### 1. Copy Zotero databases to avoid lock conflicts:
```bash
cp ~/Zotero/zotero.sqlite /tmp/zotero.sqlite
cp ~/Zotero/better-bibtex.sqlite /tmp/bbt.sqlite
```

### 2. Search for citation key in Better BibTeX database:
```bash
sqlite3 /tmp/bbt.sqlite "
SELECT itemID, itemKey, citationKey
FROM citationkey
WHERE citationKey LIKE '%<SEARCH_TERM>%';"
```

### 3. Get reference details by itemID:
```bash
sqlite3 /tmp/zotero.sqlite "
SELECT f.fieldName, idv.value
FROM itemData id
JOIN itemDataValues idv ON id.valueID = idv.valueID
JOIN fields f ON id.fieldID = f.fieldID
WHERE id.itemID = <ITEM_ID>;"
```

### 4. Check for PDF attachments:
```bash
sqlite3 /tmp/zotero.sqlite "
SELECT ia.path, ia.contentType, i.key as itemKey
FROM itemAttachments ia
JOIN items i ON ia.itemID = i.itemID
WHERE ia.parentItemID = <ITEM_ID>;"
```

### 5. PDF Location
If PDF exists, it's at: `~/Zotero/storage/<itemKey>/<filename>`

**STOP HERE** - Execute Context Checkpoint (Step 0) before reading PDF.

### 6. Report findings to user:
   - Citation key
   - Title
   - Authors (if available)
   - Date
   - Publication/Institution
   - Abstract (if available)
   - PDF location (if exists)

## Notes
- Zotero must have Better BibTeX plugin installed for citation key lookup
- If databases are locked, ensure copies are made first
- PDF can be read with the Read tool if found
