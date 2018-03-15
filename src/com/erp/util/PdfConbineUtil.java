package com.erp.util;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.List;

import com.lowagie.text.Document;
import com.lowagie.text.PageSize;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfImportedPage;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfWriter;

/**
 * PDF文件合并工具。
 * 
 * 调用方法示例：
 * byte[] pdfByte1 = JasperRunManager.runReportToPdf(......);
 * byte[] pdfByte2 = JasperRunManager.runReportToPdf(......);
 * byte[] ......
 * ......
 * PdfConbineUtil pdfConbineUtil = new PdfConbineUtil();
 * pdfConbineUtil.add(pdfByte1);
 * pdfConbineUtil.add(pdfByte2);
 * pdfConbineUtil.add(......);
 * ......
 * byte[] pdfBytes = pdfConbineUtil.conbine();
 * 
 * @author 钱佳明。
 * @version 1.0。
 * @date 2016/03/22。
 *
 */
public class PdfConbineUtil {

	/**
	 * PDF字节数据集合。
	 */
	private List<byte[]> pdfBytes = new ArrayList<byte[]>();

	/**
	 * 合并PDF文件。
	 * @return 合并后的PDF字节数据。
	 * @throws Exception
	 */
	public byte[] conbine() throws Exception {
		ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
		Document document = new Document(PageSize.A4);
		PdfWriter pdfWriter = PdfWriter.getInstance(document, byteArrayOutputStream);
		document.open();
		PdfContentByte pdfContentByte = pdfWriter.getDirectContent();
		PdfReader pdfReader = null;
		PdfImportedPage pdfImportedPage = null;
		for(byte[] pdfByte: pdfBytes) {
			pdfReader = new PdfReader(pdfByte);
			for (int index = 0; index < pdfReader.getNumberOfPages(); index++) {
				document.newPage();
				pdfImportedPage = pdfWriter.getImportedPage(pdfReader, index + 1);
				pdfContentByte.addTemplate(pdfImportedPage, 0, 0);
			}
		}
		document.close();
		return byteArrayOutputStream.toByteArray();
	}

	/**
	 * 添加PDF字节数据。
	 * @param pdfByte PDF字节数据。
	 */
	public void add(byte[] pdfByte) {
		if (pdfByte != null) {
			pdfBytes.add(pdfByte);
		}
	}

	public byte[] conbine(float width, float height) throws Exception {
		ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
		Document document = new Document(new Rectangle(width, height));
		PdfWriter pdfWriter = PdfWriter.getInstance(document, byteArrayOutputStream);
		document.open();
		PdfContentByte pdfContentByte = pdfWriter.getDirectContent();
		PdfReader pdfReader = null;
		PdfImportedPage pdfImportedPage = null;
		for(byte[] pdfByte: pdfBytes) {
			pdfReader = new PdfReader(pdfByte);
			for (int index = 0; index < pdfReader.getNumberOfPages(); index++) {
				document.newPage();
				pdfImportedPage = pdfWriter.getImportedPage(pdfReader, index + 1);
				pdfContentByte.addTemplate(pdfImportedPage, 0, 0);
			}
		}
		document.close();
		return byteArrayOutputStream.toByteArray();
	}

}