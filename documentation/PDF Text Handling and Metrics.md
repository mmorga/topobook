# PDF Text Handling and Metrics

## Graphics

Table 51 – Operator Categories

|        Category        |                  Operators                   | Table |
| ---------------------- | -------------------------------------------- | ----- |
| General graphics state | w, J, j, M, d, ri, i, gs                     |    57 |
| Special graphics state | q, Q, cm                                     |    57 |
| Path construction      | m, l, c, v, y, h, re                         |    59 |
| Path painting          | S, s, f, F, f*, B, B*, b, b*, n              |    60 |
| Clipping paths         | W, W*                                        |    61 |
| Text objects           | BT, ET                                       |   107 |
| Text state             | Tc, Tw, Tz, TL, Tf, Tr, Ts                   |       |
| Text positioning       | Td, TD, Tm, T*                               |   108 |
| Text showing           | Tj, TJ, ', "                                 |   109 |
| Type 3 fonts           | d0, d                                        |  1113 |
| Color                  | CS, cs, SC, SCN, sc, scn, G, g, RG, rg, K, k |    74 |
| Shading patterns       | sh                                           |    77 |
| Inline images          | BI, ID, EI                                   |    92 |
| XObjects               | Do                                           |    87 |
| Marked content         | MP, DP, BMC, BDC, EMC                        |   320 |
| Compatibility          | BX, EX                                       |    32 |

## Coordinate Spaces

User Space

Page dictionary CropBox

* Text State
* Text objects and operators
* Font data structures

---

```pdf
BT
  /F13 12 Tf
  288 720 Td
  (ABC) Tj
ET
```

## Fonts

* Defines glyphs at one standard size
* Nominal height of tightly spaced lines of text is 1 unit
* Default user coordinate system, standard glyph size is 1 unit in user space or 1/72 in.
    - Can be set greater than 1/72 in by means of `UserUnit` entry in page dictionary

## Text State

Table 104 – Text state parameters

| Parameter |     Description     |
| --------- | ------------------- |
| Tc        | Character spacing   |
| Tw        | Word spacing        |
| Th        | Horizontal scaling  |
| Tl        | Leading             |
| Tf        | Text font           |
| Tfs       | Text font size      |
| Tmode     | Text rendering mode |
| Trise     | Text rise           |
| Tk        | Text knockout       |

Table 105 – Text state operators

|  Operands | Operator |                                                                                                                                                                         Description                                                                                                                                                                          |
| --------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| charSpace | Tc       | Set the character spacing, Tc, to charSpace, which shall be a number expressed in unscaled text space units. Character spacing shall be used by the Tj, TJ, and ' operators. Initial value: 0.                                                                                                                                                               |
| wordSpace | Tw       | Set the word spacing, Tw, to wordSpace, which shall be a number expressed in unscaled text space units. Word spacing shall be used by the Tj, TJ, and ' operators. Initial value: 0.                                                                                                                                                                         |
| scale     | Tz       | Set the horizontal scaling, Th, to (scale ÷ 100). scale shall be a number specifying the percentage of the normal width. Initial value: 100 (normal width).                                                                                                                                                                                                  |
| leading   | TL       | Set the text leading, Tl, to leading, which shall be a number expressed in unscaled text space units. Text leading shall be used only by the T*, ', and " operators. Initial value: 0.                                                                                                                                                                       |
| font size | Tf       | Set the text font, Tf, to font and the text font size, Tfs, to size. font shall be the name of a font resource in the Font subdictionary of the current resource dictionary; size shall be a number representing a scale factor. There is no initial value for either font or size; they shall be specified explicitly by using Tf before any text is shown. |
| render    | Tr       | Set the text rendering mode, Tmode, to render, which shall be an integer. Initial value: 0.                                                                                                                                                                                                                                                                  |
| rise      | Ts       | Set the text rise, Trise, to rise, which shall be a number expressed in unscaled text space units. Initial value: 0.                                                                                                                                                                                                                                         |

Parameters valid only within text object

| Parameter |                                                                                       Description                                                                                        |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Tm        | the text matrix                                                                                                                                                                          |
| Tlm       | the text line matrix                                                                                                                                                                     |
| Trm       | the text rendering matrix, which is actually just an intermediate result that combines the effects of text state parameters, the text matrix (Tm), and the current transformation matrix |

### Text Object Operators

| Operands | Operator |                                                                                         Description                                                                                         |
| -------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| —        | BT       | Begin a text object, initializing the text matrix, Tm, and the text line matrix, Tlm , to the identity matrix. Text objects shall not be nested; a second BT shall not appear before an ET. |
| —        | ET       | End a text object, discarding the text matrix.                                                                                                                                              |

### Text-Positioning Operators

|   Operands  | Operator |                                                                                                                                                                                                                                                                                                                                                                                                       Description                                                                                                                                                                                                                                                                                                                                                                                                        |
| ----------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| tx ty       | Td       | Move to the start of the next line, offset from the start of the current line by (tx, ty). tx and ty shall denote numbers expressed in unscaled text space units. More precisely, this operator shall perform these assignments:<br/><math><mrow><msub><mi>T</mi><mi>m</mi></msub><mo>=</mo><msub><mi>T</mi><mi>lm</mi></msub><mo>=</mo><mo>&lsqb;</mo><mtable><mtr><mtd><mn>1</mn></mtd><mtd><mn>0</mn></mtd><mtd><mn>0</mn></mtd></mtr><mtr><mtd><mn>0</mn></mtd><mtd><mn>1</mn></mtd><mtd><mn>0</mn></mtd></mtr><mtr><mtd><msub><mi>t</mi><mi>x</mi></msub></mtd><mtd><msub><mi>t</mi><mi>y</mi></msub></mtd><mtd><mn>1</mn></mtd></mtr></mtable><mo>&rsqb;</mo><mo>&#xD7;</mo><msub><mi>T</mi><mi>lm</mi></msub></mrow></math><br/>                                                                                  |
| tx ty       | TD       | Move to the start of the next line, offset from the start of the current line by (tx, ty). As a side effect, this operator shall set the leading parameter in the text state. This operator shall have the same effect as this code:<br/>`−ty TL`<br/>`tx ty Td`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| a b c d e f | Tm       | Set the text matrix, Tm, and the text line matrix, Tlm: <br/><math><mrow><msub><mi>T</mi><mi>m</mi></msub><mo>=</mo><msub><mi>T</mi><mi>lm</mi></msub><mo>=</mo><mo>&lsqb;</mo><mtable><mtr><mtd><mi>a</mi></mtd><mtd><mi>b</mi></mtd><mtd><mn>0</mn></mtd></mtr><mtr><mtd><mi>c</mi></mtd><mtd><mi>d</mi></mtd><mtd><mn>0</mn></mtd></mtr><mtr><mtd><mi>e</mi></mtd><mtd><mi>f</mi></mtd><mtd><mn>1</mn></mtd></mtr></mtable><mo>&rsqb;</mo></mrow></math><br/>The operands shall all be numbers, and the initial value for Tm and Tlm shall be the identity matrix, [1 0 0 1 0 0]. Although the operands specify a matrix, they shall be passed to Tm as six separate numbers, not as an array.<br/>The matrix specified by the operands shall not be concatenated onto the current text matrix, but shall replace it. |
| —           | T*       | Move to the start of the next line. This operator has the same effect as the code `0 -Tl Td` where Tl denotes the current leading parameter in the text state. The negative of Tl is used here because Tl is the text leading expressed as a positive number. Going to the next line entails decreasing the y coordinate.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |

Table 109 – Text-showing operators

|   Operands   | Operator |                                                                                                                                                                                                                                                                                                                                                                                       Description                                                                                                                                                                                                                                                                                                                                                                                        |
| ------------ | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| string       | Tj       | Show a text string.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| string       | '        | Move to the next line and show a text string. This operator shall have the same effect as the code<br/>`T*`<br/>`string Tj`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| aw ac string | "        | Move to the next line and show a text string, using aw as the word spacing and ac as the character spacing (setting the corresponding parameters in the text state). aw and ac shall be numbers expressed in unscaled text space units. This operator shall have the same effect as this code:<br/>`aw Tw`<br/>`ac Tc`<br/>`string '`<br/>                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| array        | TJ       | Show one or more text strings, allowing individual glyph positioning. Each element of array shall be either a string or a number. If the element is a string, this operator shall show the string. If it is a number, the operator shall adjust the text position by that amount; that is, it shall translate the text matrix, Tm. The number shall be expressed in thousandths of a unit of text space (see 9.4.4, "Text Space Details"). This amount shall be subtracted from the current horizontal or vertical coordinate, depending on the writing mode. In the default coordinate system, a positive adjustment has the effect of moving the next glyph painted either to the left or down by the given amount. Figure 46 shows an example of the effect of passing offsets to TJ. |

## Text Space Details

As stated in 9.4.2, "Text-Positioning Operators", text shall be shown in text space, defined by the combination of the text matrix, Tm, and the text state parameters Tfs, Th, and Trise. This determines how text coordinates
are transformed into user space. Both the glyph’s shape and its displacement (horizontal or vertical) shall be interpreted in text space.

NOTE 1
Glyphs are actually defined in glyph space, whose definition varies according to the font type as discussed in 9.2.4, "Glyph Positioning and Metrics". Glyph coordinates are first transformed from glyph space to text space before being subjected to the transformations described in Note 2.

NOTE 2
Conceptually, the entire transformation from text space to device space may be represented by a text rendering matrix, Trm:

<math><mrow>
  <msub><mi>T</mi><mi>rm</mi></msub>
  <mo>=</mo>
  <mo>&lsqb;</mo>
  <mtable>
    <mtr>
      <mtd><mrow><msub><mi>T</mi><mi>fs</mi></msub><mo>&#xD7;</mo><msub><mi>T</mi><mi>h</mi></msub></mtd>
      <mtd><mn>0</mn></mtd>
      <mtd><mn>0</mn></mtd>
    </mtr><mtr>
      <mtd><mn>0</mn></mtd>
      <mtd><msub><mi>T</mi><mi>fs</mi></msub></mtd>
      <mtd><mn>0</mn></mtd>
    </mtr><mtr>
      <mtd><mn>0</mn></mtd>
      <mtd><msub><mi>T</mi><mi>rise</mi></msub></mtd>
      <mtd><mn>1</mn></mtd>
    </mtr>
  </mtable>
  <mo>&rsqb;</mo>
  <mo>&#xD7;</mo>
  <msub><mi>T</mi><mi>m</mi></msub>
  <mo>&#xD7;</mo>
  <mi>CTM</mi>
</mrow></math>

After the glyph is painted, the text matrix shall be updated according to the glyph displacement and any spacing parameters that apply. First, a combined displacement shall be computed, denoted by tx in horizontal writing mode or ty in vertical writing mode (the variable corresponding to the other writing mode shall be set to 0):

<math>
  <mrow>
    <msub><mi>t</mi><mi>x</mi></msub>
    <op>=</op>
    <mo>(</mo>
    <mrow>
      <mo>(</mo>
      <mrow>
        <mi>w0</mi>
        <op>-</op>
        <mfrac>
          <msub><mi>T</mi><mi>j</mi></msub>
          <mn>1000</mn>
        </mfrac>
      </mrow>
      <mo>)</mo>
      <mo>&#xD7;</mo>
      <msub><mi>T</mi><mi>fs</mi></msub>
      <mo>+</mo>
      <msub><mi>T</mi><mi>c</mi></msub>
      <mo>+</mo>
      <msub><mi>T</mi><mi>w</mi></msub>
    </mrow>
    <mo>)</mo>
    <mo>&#xD7;</mo>
    <msub><mi>T</mi><mi>h</mi></msub>
  </mrow>
</math>
<br/>
<math>
  <mrow>
    <msub><mi>t</mi><mi>y</mi></msub>
    <op>=</op>
    <mo>(</mo>
    <mrow>
      <mi>w1</mi>
      <op>-</op>
      <mfrac>
        <msub><mi>T</mi><mi>j</mi></msub>
        <mn>1000</mn>
      </mfrac>
    </mrow>
    <mo>)</mo>
    <mo>&#xD7;</mo>
    <msub><mi>T</mi><mi>fs</mi></msub>
    <mo>+</mo>
    <msub><mi>T</mi><mi>c</mi></msub>
    <mo>+</mo>
    <msub><mi>T</mi><mi>w</mi></msub>
  </mrow>
</math>

where

* w0 and w1 denote the glyph’s horizontal and vertical displacements
* Tj denotes a number in a TJ array, if any, which specifies a position adjustment
* Tfs and Th denote the current text font size and horizontal scaling parameters in the graphics state
* Tc and Tw denote the current character- and word-spacing parameters in the graphics state, if applicable

The text matrix shall then be then updated as follows:

<math><mrow>
  <msub><mi>T</mi><mi>m</mi></msub>
  <mo>=</mo>
  <mo>&lsqb;</mo>
  <mtable>
    <mtr>
      <mtd><mn>1</mn></mtd>
      <mtd><mn>0</mn></mtd>
      <mtd><mn>0</mn></mtd>
    </mtr><mtr>
      <mtd><mn>0</mn></mtd>
      <mtd><mn>1</mn></mtd>
      <mtd><mn>0</mn></mtd>
    </mtr><mtr>
      <mtd><msub><mi>t</mi><mi>x</mi></msub></mtd>
      <mtd><msub><mi>t</mi><mi>y</mi></msub></mtd>
      <mtd><mn>1</mn></mtd>
    </mtr>
  </mtable>
  <mo>&rsqb;</mo>
  <mo>&#xD7;</mo>
  <msub><mi>T</mi><mi>m</mi></msub>
</mrow></math>

