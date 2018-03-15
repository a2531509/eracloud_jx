package com.erp.dwr;

import java.awt.image.BufferedImage;
import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Blob;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.imageio.ImageIO;

import org.springframework.stereotype.Component;

import sun.misc.BASE64Decoder;

import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.BasePhoto;
import com.erp.service.BasicPhotoService;
@Component(value="fileDealDwr")
public class FileDealDwr {
	private BasicPhotoService basicPhotoService;
    @Resource(name="basicPhotoService")
   	public void setBasicPhotoService(BasicPhotoService basicPhotoService ){
   		this.basicPhotoService = basicPhotoService;
   	}
    /**
     * 客户照片管理根据客户编号获取照片信息
     * @param clientId 客户编号
     * @return 状态信息
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })
	public Map getImgMessage(String clientId){
    	Map map = new HashMap();
    	map.put("isOK","0");
		map.put("errMsg", "");
    	try {
    		BufferedImage image  =  null;
    		ByteArrayInputStream in = null;
			List<BasePhoto> photoList =basicPhotoService.findPhotoByClientId(clientId);
			if(photoList == null || photoList.size() <= 0){
				photoList  = basicPhotoService.findPhotoByClientId("9999999999");
			}
			if(photoList != null && photoList.size() > 0){
				in= new ByteArrayInputStream(blobToBytes(photoList.get(0).getPhoto()));
				image = ImageIO.read(in);
			}else{
				throw new CommonException("系统未配置默认显示的照片");
			}
			map.put("imageMsg", image);
		} catch (Exception e) {
			map.put("isOK","1");
			map.put("errMsg",e.getMessage());
		}
		return map;
    }
    /**
     * 读身份证转换照片信息
     * @param content base64编码的照片信息
     * @return 状态
     */
    @SuppressWarnings({ "unchecked", "rawtypes"})
	public Map getImgMessageByCard(String content){
    	Map map = new HashMap();
    	map.put("isOK","0");
		map.put("errMsg","");
    	try {
			BufferedImage image  =  null;
			ByteArrayInputStream in =null;
		    BASE64Decoder decoder = new BASE64Decoder();
			byte[] bytes = decoder.decodeBuffer(content);  
			in = new ByteArrayInputStream(bytes);
			image = ImageIO.read(in);
			map.put("imageMsg",image);
		} catch (Exception e) {
			map.put("isOK", "1");
			map.put("errMsg",e.getMessage());
		}
		return map;
    }
    public Map getImgMessageByCertNo(String certNo){
    	Map map = new HashMap();
    	try {
			List<BasePersonal> personlists = basicPhotoService.findByHql("from BasePersonal where certNo ='" + certNo + "'");
			if (personlists == null || personlists.size() != 1) {
				throw new CommonException("人员信息不存在或查询到多个人员信息，请联系系统管理员！");
			}
			List<BasePhoto> photoList = basicPhotoService.findPhotoByClientId(personlists.get(0).getCustomerId().toString());
			if (photoList == null || photoList.size() <= 0) {
				photoList = basicPhotoService.findPhotoByClientId("9999999999");
			}
			BufferedImage image = null;
			ByteArrayInputStream in = null;
		
			if(photoList!=null&&photoList.size()>0){
				in= new ByteArrayInputStream(blobToBytes(photoList.get(0).getPhoto()));
				image = ImageIO.read(in);
			}else{
				throw new CommonException("系统未配置默认显示的照片，请联系系统管理员！");
			}
			map.put("imageMsg", image);
			map.put("isOK", "0");
		} catch (Exception e) {
			map.put("isOK", "1");
			e.printStackTrace();
		}
		return map;
    }
    private  byte[] blobToBytes(Blob blob) {
        BufferedInputStream is = null;
        byte[] bytes = null;
        try {
            is = new BufferedInputStream(blob.getBinaryStream());
            bytes = new byte[(int) blob.length()];
            int len = bytes.length;
            int offset = 0;
            int read = 0;
 
            while (offset < len
                    && (read = is.read(bytes, offset, len - offset)) >= 0) {
                offset += read;
            }
 
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bytes;
 
    }
    
    public  byte[] getBytesFromFile(File file) {  
        byte[] ret = null;  
        try {  
            if (file == null) {  
                return null;  
            }  
            FileInputStream in = new FileInputStream(file);  
            ByteArrayOutputStream out = new ByteArrayOutputStream(4096);  
            byte[] b = new byte[4096];  
            int n;  
            while ((n = in.read(b)) != -1) {  
                out.write(b, 0, n);  
            }  
            in.close();  
            out.close();  
            ret = out.toByteArray();  
        } catch (IOException e) {  
            e.printStackTrace();  
        }  
        return ret;  
    } 

//    public FileTransfer createExcel() throws Exception{
//    	ByteArrayOutputStream out = new ByteArrayOutputStream();  //使用这个文件流存放输出文件  
//    	 byte[] temp = new byte[1024];    
//    	 wb.write(out);  
//    	 out.close();  
//    	String  filename ="sss.xls";                       //默认输出值为filename的值  
//    	return new FileTransfer(filename,"application/vnd.ms-excel", out.toByteArray());
//
//    }
    	
}
