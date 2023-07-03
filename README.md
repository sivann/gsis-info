# gsis_info
Get various info from AADE/GSIS, command line

For now just debt is supported (Οφειλές)

```
./gsis-info.sh <username> <password>
   ΑΦΜ                                   063563360
   Μη Ληξιπρόθεσμο Υπόλοιπο Οφειλών          0,00 €
   Ληξιπρόθεσμο Υπόλοιπο Οφειλών           100,00 €
   Προσαυξήσεις,Τόκοι,τέλη                   2,40 €
   Συνολικό Ποσό Οφειλών εκτός ρύθμισης    102,40 €
   Name: ΙΩΑΝΝΟΥ ΒΑΣ. ΣΠΥΡΙΔΩΝ
   Vat: 063563360
   Queried on: 2023-07-03T090759

```

How to email results:

```
cat out/<username>/<username>.debtinfo.html | mail -s 'Οφειλές' -M "text/html"  your_email@xyz.com
```


