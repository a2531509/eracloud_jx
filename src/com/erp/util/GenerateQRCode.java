package com.erp.util;

import java.awt.Color;

import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;

import javax.imageio.ImageIO;

import com.swetake.util.Qrcode;
/**
 * 二维码生成工具
 * @author yangning
 * @email yn_yangning@foxmail.com
 * @version 1.0
 */
public class GenerateQRCode {
	public static int _IMAGE_WIDTH = 90;//生成二维码的默认宽度
	public static int _IMAGE_HEIGHT = 90;//生成二维码的默认高度
	
	public static void main(String[] args) throws Exception {
		BufferedImage image = GenerateQRCode.createQRCode("我的QQ:346038186");
		if(image != null){
			File c = new File("c:\\123.png");
			if(!c.exists()){
				c.createNewFile();
			}
			ImageIO.write(image, "PNG",c);
		}
	}
	/**
	 * 根据给定的content内容生成想对应的二维码图片
	 * @param content  String 需要生成二维码的字符串格式数据
	 * @return BufferedImage 生成的图片
	 */
	public static BufferedImage createQRCode(String content) throws Exception{
		BufferedImage image = null;
		try{
			Qrcode  code = new Qrcode();
			code.setQrcodeErrorCorrect('M');
			code.setQrcodeEncodeMode('B');
			code.setQrcodeVersion(7);
			byte[] _c = content.getBytes("UTF-8");
			image = new BufferedImage(_IMAGE_WIDTH,_IMAGE_HEIGHT,BufferedImage.TYPE_INT_RGB);//创建一个图片缓冲区
			Graphics2D g = image.createGraphics();//创建一个画板
			g.setBackground(Color.WHITE);//设置画板的背景颜色
			g.clearRect(0, 0,_IMAGE_WIDTH,_IMAGE_WIDTH);//设置绘制区域
			g.setColor(Color.BLACK);//设置画笔颜色
			//判断生成二维码的原始数据是否超过最大的限制 限制最大的字节数119 
			if(_c.length > 0 && _c.length < 120){
				boolean[][] _d = code.calQrcode(_c);
				for (int i = 0; i < _d.length; i++) {
					for (int j = 0; j < _d.length; j++) {
						if(_d[j][i]){
							g.fillRect(j * 2, i * 2,2,2);
						}
					}
				}
			}else{
				throw new Exception("生成二维码的原始内容长度不符合要求！");
			}
			g.dispose();
			image.flush();
		}catch(Exception e){
			throw e;
		}
		return image;
	}
	/**
	 * 根据给定的content内容生成想对应的二维码图片
	 * @param content  String 需要生成二维码的字符串格式数据
	 * @param targerWidth  int 生成二维码的宽度
	 * @param targetHeight int 生成二维码的高度
	 * @return  BufferedImage 生成的图片           
	 * @throws Exception
	 */
	public static BufferedImage createQRCode(String content,int targerWidth,int targetHeight) throws Exception{
		BufferedImage image = null;
		try{
		    Qrcode  code = new Qrcode();
			code.setQrcodeErrorCorrect('M');
			code.setQrcodeEncodeMode('B');
			code.setQrcodeVersion(1);
			byte[] _c = content.getBytes("UTF-8");
			image = new BufferedImage(targerWidth,targetHeight,BufferedImage.TYPE_INT_RGB);//创建一个图片缓冲区
			Graphics2D g = image.createGraphics();//创建一个画板
			g.setBackground(Color.WHITE);//设置画板的背景颜色
			g.clearRect(0, 0,targerWidth,targetHeight);//设置绘制区域
			g.setColor(Color.BLACK);//设置画笔颜色
			//判断生成二维码的原始数据是否超过最大的限制 限制最大的字节数119 
			if(_c.length > 0 && _c.length < 120){
				boolean[][] _d = code.calQrcode(_c);
				for (int i = 0; i < _d.length; i++) {
					for (int j = 0; j < _d.length; j++) {
						if(_d[j][i]){
							g.fillRect(j * 2, i * 2,2,2);
						}
					}
				}
			}else{
				throw new Exception("生成二维码的原始内容长度不符合要求！");
			}
			g.dispose();
			image.flush();
		}catch(Exception e){
			throw e;
		}
		return image;
	}
}
