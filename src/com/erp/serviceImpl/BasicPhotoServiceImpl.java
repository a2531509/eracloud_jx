package com.erp.serviceImpl;


import java.awt.image.BufferedImage;
import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import javax.imageio.ImageIO;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.BasePhoto;
import com.erp.model.SysActionLog;
import com.erp.service.BasicPhotoService;
import com.erp.util.CardIdValidator;
import com.erp.util.CheckIdCardUtils;
import com.erp.util.Constants;
import com.erp.util.Tools;

@Service("basicPhotoService")
@SuppressWarnings("rawtypes")
public class BasicPhotoServiceImpl extends BaseServiceImpl implements BasicPhotoService {

	
	public boolean persistenceBasicPhoto(BasePhoto photo,byte[] filebyte,SysActionLog actionLog) {
		try {
			publicDao.save(actionLog);
			List<BasePhoto> photoList = publicDao.find("from BasePhoto where customerId='"+photo.getCustomerId()+"'");
			if(photoList!=null&&photoList.size()>0){
				publicDao.updatePhotoImg(photoList.get(0),filebyte);
			}else{
				publicDao.savePhotoImg(photo,filebyte);
			}
		} catch (Exception e) {
			throw new CommonException("照片导入发生错误："+e.getMessage());
		}
		return true;
	}
	public Integer deleteBasicPhotoByClientId(String clientId) {
		return publicDao.executeHql("delete from BasicPhoto where customerId='"+clientId+"'" );
	}
	public List<BasePhoto> findPhotoByClientId(String clientId) {
		return publicDao.find("from BasePhoto where customerId='"+clientId+"'");
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public void saveImportPhoto(File zipFile, String uploadType, SysActionLog actionLog) throws CommonException {
		try {
			publicDao.save(actionLog);
			HashMap hash=new HashMap();
			String incertNo="";
			String inCustomerId = "";
			Set dqphoto = new HashSet();
			ZipInputStream zipIn = new ZipInputStream(new BufferedInputStream(new FileInputStream(zipFile)));
			ZipEntry zipEntry;
			BufferedImage image;
			Map<String, String> errInfo = new HashMap<String, String>();
			while ((zipEntry = zipIn.getNextEntry()) != null) {
				String[] str = zipEntry.getName().split("\\.");
				image = ImageIO.read(zipIn);
				int height = Integer.parseInt(getSysConfigurationParameters("PHOTO_HEIGHT"));
				int width = Integer.parseInt(getSysConfigurationParameters("PHOTO_WIDTH"));
				if (image.getHeight() != height || image.getWidth() != width) {
					errInfo.put(str[0], "图片尺寸不正确 [正确尺寸: " + width + "x" + height + "].");
					continue;
				}
				if (str != null) {
					if(uploadType.equals("0")) {
						if(str[0].length()==15){
							str[0]=CardIdValidator.cardidto18(str[0]);
						}//330327197002193518
						 //330327197002193518
						if (!CheckIdCardUtils.validateIdCard18(Tools.processNull(str[0]))) {
							errInfo.put(str[0], "照片文件名为"+str[0]+"对应的身份证号不正确!");
							continue;
						}
						incertNo += "'"+str[0].toUpperCase()+"',";
					} else if (uploadType.equals("1")) {
						if (!str[0].matches("[0-9]+")) {
							errInfo.put(str[0], "照片文件名为"+str[0]+"对应的客户编号应全为数字!");
							continue;
						}
						inCustomerId += "'" + str[0] + "',";
					}
					dqphoto.add(str[0].toUpperCase());
				}
				ByteArrayOutputStream bytestream = new ByteArrayOutputStream();
				ImageIO.write(image, "jpg", bytestream);
				hash.put(str[0].toUpperCase(),bytestream.toByteArray());
				bytestream.close();
			}
			if(!errInfo.isEmpty()){
				String errMsg = "";
				for(String key:errInfo.keySet()){
					errMsg += "【" + key + "】，" + errInfo.get(key) + "<br>";
				}
				throw new CommonException(errMsg);
			}
			List list = null;
			if(!incertNo.equals("") && uploadType.equals("0")){
				list = this.findBySql("select b.customer_id,b.cert_No from base_personal b where b.cert_No in("+ incertNo.substring(0,incertNo.length()-1)+")");
				if(list.size()!=hash.size()){
					String str="";
					for(int i=0;i<list.size();i++){
						Object[] o = (Object[])list.get(i);
						if(dqphoto.contains(Tools.processNull(o[1]))) {
							dqphoto.remove(Tools.processNull(o[1]));
						} else {
							str+="'"+o[1]+"',";
						}
					}
					if(!"".equals(str)) {
						throw new CommonException(str+"数据已存在。");
					}
					String notexist="";
					for(Iterator ite=dqphoto.iterator();ite.hasNext();){
						notexist+=ite.next()+",";
					}
					throw new CommonException("有"+ (hash.size()-list.size())+"张照片对应的基础数据不存在：照片文件如下<br>"+notexist.substring(0,notexist.length()-1));
				}
			} else if (!inCustomerId.equals("") && uploadType.equals("1")) {
				list = this.findBySql("select b.customer_id,b.cert_No from base_personal b where b.customer_Id in("+ inCustomerId.substring(0,inCustomerId.length()-1)+")");
				if(list.size()!=hash.size()){
					String str="";
					for(int i=0;i<list.size();i++){
						Object[] o = (Object[])list.get(i);
						if(dqphoto.contains(Tools.processNull(o[0]))) {
							dqphoto.remove(Tools.processNull(o[0]));
						} else {
							str+="'"+o[0]+"',";
						}
					}
					if(!"".equals(str)) {
						throw new CommonException(str+"数据已存在。");
					}
					String notexist="";
					for(Iterator ite=dqphoto.iterator();ite.hasNext();){
						notexist+=ite.next()+",";
					}
					throw new CommonException("有"+ (hash.size()-list.size())+"张照片对应的基础数据不存在：照片文件如下<br>"+notexist.substring(0,notexist.length()-1));
				}
			} else {
				throw new CommonException("当前导入压缩文件中没有照片");
			}
			for(int i=0;i<list.size();i++){
				Object[] o = (Object[])list.get(i);
				BasePhoto photo= new BasePhoto();
				photo.setCustomerId((String)o[0]);
				photo.setPhotoState(Constants.STATE_ZC);
				List<BasePhoto> photoList = publicDao.find("from BasePhoto where customerId='"+(String)o[0]+"'");
				if(photoList!=null&&photoList.size()>0){
					if(uploadType.equals("0")) {
						publicDao.updatePhotoImg(photoList.get(0),(byte[])hash.get((String)o[1]));
					} else if(uploadType.equals("1")) {
						publicDao.updatePhotoImg(photoList.get(0),(byte[])hash.get((String)o[0]));
					}
				}else{
					if(uploadType.equals("0")) {
						publicDao.savePhotoImg(photo,(byte[])hash.get((String)o[1]));
					} else if(uploadType.equals("1")) {
						publicDao.savePhotoImg(photo,(byte[])hash.get((String)o[0]));
					}
				}
			}
		} catch (Exception e) {
			throw new CommonException("批量导入照片发生错误：", e);
		}
	}
}
