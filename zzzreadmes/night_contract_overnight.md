# Night Contract Report

- Started: 2026-07-10 05:16:03.417569
- Finished: 2026-07-10 13:12:24.477389
- Duration: 28581059 ms
- Limit: all
- Minutes: 480
- Interrupted: true
- Checkpoint every: 5000 checked states

## Summary

| Bucket | Count |
| --- | ---: |
| Checked | 125630000 |
| Passed | 125579950 |
| Ambiguous | 50050 |
| State drift | 0 |
| Failed | 0 |
| Skipped | 4575230 |

## Skips

| Reason | Count |
| --- | ---: |
| imperative recognition is not implemented yet | 4171 |
| passive voice requires an object-capable verb | 538014 |
| modal samples are constrained to present tense | 4028874 |
| lexical be is not implemented as a regular predicate | 4171 |

## ambiguous

Showing first 50 findings.

### cycle-1:active:cut:32752

- Bucket: `active`
- State: `agent=we, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=null, manner=null`
- First sentence: `We cut.`
- Second sentence: `We cut.`
- Expected: `agent=we/Person.first/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=null`
- Actual: `agent=we/Person.first/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=null`
- Unknown tokens: `[We]`

### cycle-1:phrase-time:cut:32896

- Bucket: `phrase-time`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=yesterday, place=null, frequency=null, manner=null`
- First sentence: `They cut yesterday.`
- Second sentence: `They cut yesterday.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=yesterday|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=yesterday|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, yesterday]`

### cycle-1:phrase-time:cut:32897

- Bucket: `phrase-time`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=tomorrow, place=null, frequency=null, manner=null`
- First sentence: `They cut tomorrow.`
- Second sentence: `They cut tomorrow.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=tomorrow|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=tomorrow|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, tomorrow]`

### cycle-1:phrase-time:cut:32898

- Bucket: `phrase-time`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=now, place=null, frequency=null, manner=null`
- First sentence: `They cut now.`
- Second sentence: `They cut now.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=now|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=now|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, now]`

### cycle-1:phrase-place:cut:32899

- Bucket: `phrase-place`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=home, frequency=null, manner=null`
- First sentence: `They cut at home.`
- Second sentence: `They cut at home.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at home|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at home|frequency=null|manner=null`
- Unknown tokens: `[They, at, home]`

### cycle-1:phrase-place:cut:32900

- Bucket: `phrase-place`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=school, frequency=null, manner=null`
- First sentence: `They cut at school.`
- Second sentence: `They cut at school.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at school|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at school|frequency=null|manner=null`
- Unknown tokens: `[They, at, school]`

### cycle-1:phrase-place:cut:32901

- Bucket: `phrase-place`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=work, frequency=null, manner=null`
- First sentence: `They cut at work.`
- Second sentence: `They cut at work.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at work|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at work|frequency=null|manner=null`
- Unknown tokens: `[They, at]`

### cycle-1:phrase-frequency:cut:32903

- Bucket: `phrase-frequency`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=every day, manner=null`
- First sentence: `They cut every day.`
- Second sentence: `They cut every day.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=every day|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=every day|manner=null`
- Unknown tokens: `[They, day]`

### cycle-1:phrase-manner:cut:32904

- Bucket: `phrase-manner`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=null, manner=quickly`
- First sentence: `They cut quickly.`
- Second sentence: `They cut quickly.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=quickly`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=quickly`
- Unknown tokens: `[They, quickly]`

### cycle-1:phrase-manner:cut:32905

- Bucket: `phrase-manner`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=null, manner=carefully`
- First sentence: `They cut carefully.`
- Second sentence: `They cut carefully.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=carefully`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=carefully`
- Unknown tokens: `[They, carefully]`

### cycle-1:active:hit:138892

- Bucket: `active`
- State: `agent=they, action=hit, object=letter, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.exclamation, time=null, place=null, frequency=null, manner=null`
- First sentence: `They hit the letter!`
- Second sentence: `They hit the letter!`
- Expected: `agent=they/Person.third/Number.plural/null/|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, letter]`

### cycle-1:active:hit:138940

- Bucket: `active`
- State: `agent=workers, action=hit, object=letter, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.past, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.exclamation, time=null, place=null, frequency=null, manner=null`
- First sentence: `The old workers hit the letter!`
- Second sentence: `The old workers hit the letter!`
- Expected: `agent=workers/Person.third/Number.plural/the/old|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Actual: `agent=workers/Person.third/Number.plural/the/old|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Unknown tokens: `[workers, letter]`

### cycle-2:active:cut:32752

- Bucket: `active`
- State: `agent=we, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=null, manner=null`
- First sentence: `We cut.`
- Second sentence: `We cut.`
- Expected: `agent=we/Person.first/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=null`
- Actual: `agent=we/Person.first/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=null`
- Unknown tokens: `[We]`

### cycle-2:phrase-time:cut:32896

- Bucket: `phrase-time`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=yesterday, place=null, frequency=null, manner=null`
- First sentence: `They cut yesterday.`
- Second sentence: `They cut yesterday.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=yesterday|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=yesterday|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, yesterday]`

### cycle-2:phrase-time:cut:32897

- Bucket: `phrase-time`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=tomorrow, place=null, frequency=null, manner=null`
- First sentence: `They cut tomorrow.`
- Second sentence: `They cut tomorrow.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=tomorrow|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=tomorrow|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, tomorrow]`

### cycle-2:phrase-time:cut:32898

- Bucket: `phrase-time`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=now, place=null, frequency=null, manner=null`
- First sentence: `They cut now.`
- Second sentence: `They cut now.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=now|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=now|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, now]`

### cycle-2:phrase-place:cut:32899

- Bucket: `phrase-place`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=home, frequency=null, manner=null`
- First sentence: `They cut at home.`
- Second sentence: `They cut at home.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at home|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at home|frequency=null|manner=null`
- Unknown tokens: `[They, at, home]`

### cycle-2:phrase-place:cut:32900

- Bucket: `phrase-place`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=school, frequency=null, manner=null`
- First sentence: `They cut at school.`
- Second sentence: `They cut at school.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at school|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at school|frequency=null|manner=null`
- Unknown tokens: `[They, at, school]`

### cycle-2:phrase-place:cut:32901

- Bucket: `phrase-place`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=work, frequency=null, manner=null`
- First sentence: `They cut at work.`
- Second sentence: `They cut at work.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at work|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at work|frequency=null|manner=null`
- Unknown tokens: `[They, at]`

### cycle-2:phrase-frequency:cut:32903

- Bucket: `phrase-frequency`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=every day, manner=null`
- First sentence: `They cut every day.`
- Second sentence: `They cut every day.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=every day|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=every day|manner=null`
- Unknown tokens: `[They, day]`

### cycle-2:phrase-manner:cut:32904

- Bucket: `phrase-manner`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=null, manner=quickly`
- First sentence: `They cut quickly.`
- Second sentence: `They cut quickly.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=quickly`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=quickly`
- Unknown tokens: `[They, quickly]`

### cycle-2:phrase-manner:cut:32905

- Bucket: `phrase-manner`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=null, manner=carefully`
- First sentence: `They cut carefully.`
- Second sentence: `They cut carefully.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=carefully`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=carefully`
- Unknown tokens: `[They, carefully]`

### cycle-2:active:hit:138892

- Bucket: `active`
- State: `agent=they, action=hit, object=letter, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.exclamation, time=null, place=null, frequency=null, manner=null`
- First sentence: `They hit the letter!`
- Second sentence: `They hit the letter!`
- Expected: `agent=they/Person.third/Number.plural/null/|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, letter]`

### cycle-2:active:hit:138940

- Bucket: `active`
- State: `agent=workers, action=hit, object=letter, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.past, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.exclamation, time=null, place=null, frequency=null, manner=null`
- First sentence: `The old workers hit the letter!`
- Second sentence: `The old workers hit the letter!`
- Expected: `agent=workers/Person.third/Number.plural/the/old|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Actual: `agent=workers/Person.third/Number.plural/the/old|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Unknown tokens: `[workers, letter]`

### cycle-3:active:cut:32752

- Bucket: `active`
- State: `agent=we, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=null, manner=null`
- First sentence: `We cut.`
- Second sentence: `We cut.`
- Expected: `agent=we/Person.first/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=null`
- Actual: `agent=we/Person.first/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=null`
- Unknown tokens: `[We]`

### cycle-3:phrase-time:cut:32896

- Bucket: `phrase-time`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=yesterday, place=null, frequency=null, manner=null`
- First sentence: `They cut yesterday.`
- Second sentence: `They cut yesterday.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=yesterday|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=yesterday|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, yesterday]`

### cycle-3:phrase-time:cut:32897

- Bucket: `phrase-time`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=tomorrow, place=null, frequency=null, manner=null`
- First sentence: `They cut tomorrow.`
- Second sentence: `They cut tomorrow.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=tomorrow|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=tomorrow|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, tomorrow]`

### cycle-3:phrase-time:cut:32898

- Bucket: `phrase-time`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=now, place=null, frequency=null, manner=null`
- First sentence: `They cut now.`
- Second sentence: `They cut now.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=now|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=now|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, now]`

### cycle-3:phrase-place:cut:32899

- Bucket: `phrase-place`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=home, frequency=null, manner=null`
- First sentence: `They cut at home.`
- Second sentence: `They cut at home.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at home|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at home|frequency=null|manner=null`
- Unknown tokens: `[They, at, home]`

### cycle-3:phrase-place:cut:32900

- Bucket: `phrase-place`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=school, frequency=null, manner=null`
- First sentence: `They cut at school.`
- Second sentence: `They cut at school.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at school|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at school|frequency=null|manner=null`
- Unknown tokens: `[They, at, school]`

### cycle-3:phrase-place:cut:32901

- Bucket: `phrase-place`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=work, frequency=null, manner=null`
- First sentence: `They cut at work.`
- Second sentence: `They cut at work.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at work|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at work|frequency=null|manner=null`
- Unknown tokens: `[They, at]`

### cycle-3:phrase-frequency:cut:32903

- Bucket: `phrase-frequency`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=every day, manner=null`
- First sentence: `They cut every day.`
- Second sentence: `They cut every day.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=every day|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=every day|manner=null`
- Unknown tokens: `[They, day]`

### cycle-3:phrase-manner:cut:32904

- Bucket: `phrase-manner`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=null, manner=quickly`
- First sentence: `They cut quickly.`
- Second sentence: `They cut quickly.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=quickly`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=quickly`
- Unknown tokens: `[They, quickly]`

### cycle-3:phrase-manner:cut:32905

- Bucket: `phrase-manner`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=null, manner=carefully`
- First sentence: `They cut carefully.`
- Second sentence: `They cut carefully.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=carefully`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=carefully`
- Unknown tokens: `[They, carefully]`

### cycle-3:active:hit:138892

- Bucket: `active`
- State: `agent=they, action=hit, object=letter, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.exclamation, time=null, place=null, frequency=null, manner=null`
- First sentence: `They hit the letter!`
- Second sentence: `They hit the letter!`
- Expected: `agent=they/Person.third/Number.plural/null/|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, letter]`

### cycle-3:active:hit:138940

- Bucket: `active`
- State: `agent=workers, action=hit, object=letter, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.past, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.exclamation, time=null, place=null, frequency=null, manner=null`
- First sentence: `The old workers hit the letter!`
- Second sentence: `The old workers hit the letter!`
- Expected: `agent=workers/Person.third/Number.plural/the/old|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Actual: `agent=workers/Person.third/Number.plural/the/old|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Unknown tokens: `[workers, letter]`

### cycle-4:active:cut:32752

- Bucket: `active`
- State: `agent=we, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=null, manner=null`
- First sentence: `We cut.`
- Second sentence: `We cut.`
- Expected: `agent=we/Person.first/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=null`
- Actual: `agent=we/Person.first/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=null`
- Unknown tokens: `[We]`

### cycle-4:phrase-time:cut:32896

- Bucket: `phrase-time`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=yesterday, place=null, frequency=null, manner=null`
- First sentence: `They cut yesterday.`
- Second sentence: `They cut yesterday.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=yesterday|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=yesterday|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, yesterday]`

### cycle-4:phrase-time:cut:32897

- Bucket: `phrase-time`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=tomorrow, place=null, frequency=null, manner=null`
- First sentence: `They cut tomorrow.`
- Second sentence: `They cut tomorrow.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=tomorrow|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=tomorrow|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, tomorrow]`

### cycle-4:phrase-time:cut:32898

- Bucket: `phrase-time`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=now, place=null, frequency=null, manner=null`
- First sentence: `They cut now.`
- Second sentence: `They cut now.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=now|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=now|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, now]`

### cycle-4:phrase-place:cut:32899

- Bucket: `phrase-place`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=home, frequency=null, manner=null`
- First sentence: `They cut at home.`
- Second sentence: `They cut at home.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at home|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at home|frequency=null|manner=null`
- Unknown tokens: `[They, at, home]`

### cycle-4:phrase-place:cut:32900

- Bucket: `phrase-place`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=school, frequency=null, manner=null`
- First sentence: `They cut at school.`
- Second sentence: `They cut at school.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at school|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at school|frequency=null|manner=null`
- Unknown tokens: `[They, at, school]`

### cycle-4:phrase-place:cut:32901

- Bucket: `phrase-place`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=work, frequency=null, manner=null`
- First sentence: `They cut at work.`
- Second sentence: `They cut at work.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at work|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=at work|frequency=null|manner=null`
- Unknown tokens: `[They, at]`

### cycle-4:phrase-frequency:cut:32903

- Bucket: `phrase-frequency`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=every day, manner=null`
- First sentence: `They cut every day.`
- Second sentence: `They cut every day.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=every day|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=every day|manner=null`
- Unknown tokens: `[They, day]`

### cycle-4:phrase-manner:cut:32904

- Bucket: `phrase-manner`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=null, manner=quickly`
- First sentence: `They cut quickly.`
- Second sentence: `They cut quickly.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=quickly`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=quickly`
- Unknown tokens: `[They, quickly]`

### cycle-4:phrase-manner:cut:32905

- Bucket: `phrase-manner`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=null, manner=carefully`
- First sentence: `They cut carefully.`
- Second sentence: `They cut carefully.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=carefully`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=carefully`
- Unknown tokens: `[They, carefully]`

### cycle-4:active:hit:138892

- Bucket: `active`
- State: `agent=they, action=hit, object=letter, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.exclamation, time=null, place=null, frequency=null, manner=null`
- First sentence: `They hit the letter!`
- Second sentence: `They hit the letter!`
- Expected: `agent=they/Person.third/Number.plural/null/|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, letter]`

### cycle-4:active:hit:138940

- Bucket: `active`
- State: `agent=workers, action=hit, object=letter, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.past, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.exclamation, time=null, place=null, frequency=null, manner=null`
- First sentence: `The old workers hit the letter!`
- Second sentence: `The old workers hit the letter!`
- Expected: `agent=workers/Person.third/Number.plural/the/old|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Actual: `agent=workers/Person.third/Number.plural/the/old|action=hit|object=letter/Person.third/Number.singular/the/|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.exclamation|time=null|place=null|frequency=null|manner=null`
- Unknown tokens: `[workers, letter]`

### cycle-5:active:cut:32752

- Bucket: `active`
- State: `agent=we, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=null, place=null, frequency=null, manner=null`
- First sentence: `We cut.`
- Second sentence: `We cut.`
- Expected: `agent=we/Person.first/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=null`
- Actual: `agent=we/Person.first/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=null|place=null|frequency=null|manner=null`
- Unknown tokens: `[We]`

### cycle-5:phrase-time:cut:32896

- Bucket: `phrase-time`
- State: `agent=they, action=cut, object=null, recipient=null, voice=Voice.active, passiveFocus=null, tense=Tense.present, aspect=Aspect.simple, modal=, polarity=Polarity.positive, form=SentenceForm.statement, time=yesterday, place=null, frequency=null, manner=null`
- First sentence: `They cut yesterday.`
- Second sentence: `They cut yesterday.`
- Expected: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.present|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=yesterday|place=null|frequency=null|manner=null`
- Actual: `agent=they/Person.third/Number.plural/null/|action=cut|object=null|recipient=null|voice=Voice.active|passiveFocus=null|tense=Tense.past|aspect=Aspect.simple|modal=|polarity=Polarity.positive|form=SentenceForm.statement|time=yesterday|place=null|frequency=null|manner=null`
- Unknown tokens: `[They, yesterday]`

