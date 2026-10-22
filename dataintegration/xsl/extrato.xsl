<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/extratos">
    <html>
      <head>
        <meta charset="UTF-8"/>
        <title>Extratos de Proprietários</title>
        <style>
          body { text-align: center; }
          table { margin: 0 auto; }
          th, td { text-align: center; padding: 4px 8px; }
        </style>
      </head>
      <body>
        <h1>Extratos Mensais de Proprietários</h1>
        <table border="1">
          <tr>
            <th>Proprietário</th><th>Ano</th><th>Mês</th><th>Pagamentos</th>
            <th>Receita (€)</th><th>Comissão %</th><th>Comissão (€)</th>
            <th>Despesas (€)</th><th>Líquido (€)</th>
          </tr>
          <xsl:for-each select="extrato">
            <tr>
              <td><xsl:value-of select="nome"/></td>
              <td><xsl:value-of select="ano"/></td>
              <td><xsl:value-of select="mes"/></td>
              <td><xsl:value-of select="n_pagamentos"/></td>
              <td><xsl:value-of select="receita_eur"/></td>
              <td><xsl:value-of select="comissao_pct"/></td>
              <td><xsl:value-of select="comissao_eur"/></td>
              <td><xsl:value-of select="despesas_eur"/></td>
              <td><xsl:value-of select="liquido_eur"/></td>
            </tr>
          </xsl:for-each>
        </table>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
