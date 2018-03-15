package com.erp.action;

import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.util.List;

import javax.imageio.ImageIO;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.springframework.beans.factory.annotation.Autowired;

import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.BasePhoto;
import com.erp.model.SysActionLog;
import com.erp.service.BasicPhotoService;
import com.erp.util.DealCode;
import com.erp.util.FileIO;
import com.erp.util.Tools;
import com.erp.viewModel.Page;
import com.opensymphony.xwork2.ModelDriven;

import sun.misc.BASE64Decoder;

@Namespace("/basicPhotoAction")
@Action(value = "basicPhotoAction")
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class BasicPhotoAction extends BaseAction implements ModelDriven<BasePhoto>{
	private static final long serialVersionUID = -2946182036619744959L;
	private BasicPhotoService basicPhotoService;
	private BasePhoto basicPhoto;
	private String uploadType;
	private File[] file;              
    private String[] fileFileName;    
    private String[] filePath;        
    private String personPhotoId;
    private String photoProcessData;
    public String name = "";
    public String certNo = "";
    public String queryType = "1";
    public String personPhotoContent = "";
    
	/**
	 * 按条件查询人员信息列表
	 * @return
	 */
	public String findPersonAllList(){
		try {
			this.initBaseDataGrid();
			if(this.queryType.equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT T1.CUSTOMER_ID,T1.CERT_TYPE,T1.CERT_NO,T1.NAME,T1.BIRTHDAY,T1.NATION,T1.RESIDE_ADDR,");
				sb.append("(SELECT COUNT(*) FROM BASE_PHOTO T2 WHERE T2.CUSTOMER_ID = T1.CUSTOMER_ID AND T2.PHOTO_STATE = '0' AND LENGTHB(T2.PHOTO) > 0 ) ISPHOTO, ");
				sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CERT_TYPE' AND CODE_VALUE = T1.CERT_TYPE) CERTTYPE, ");
				sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'NATION' AND CODE_VALUE = T1.NATION) NATIONSTR ");
				sb.append("FROM BASE_PERSONAL T1 WHERE 1 = 1 ");
				if(!Tools.processNull(name).equals("")){
					sb.append("AND T1.NAME = '").append(name.trim()).append("'");
				}
				if(!Tools.processNull(certNo).equals("")){
					sb.append("AND T1.CERT_NO = '").append(certNo.trim()).append("' ");
				}
				Page pages = basicPhotoService.pagingQuery(sb.toString(),page,rows);
				if(pages.getAllRs() != null){
					jsonObject.put("rows",pages.getAllRs());
					jsonObject.put("total", pages.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到照片信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 客户文件上传
	 * @return
	 */
	public String fileUpload(){
		try {
			jsonObject.put("status",0);
			jsonObject.put("errMsg",0);
			jsonObject.put("title", "系统消息");
			SysActionLog actionLog = basicPhotoService.getCurrentActionLog();
			actionLog.setDealCode(DealCode.PHOTO_IMPORT_SIGNONE);
			actionLog.setMessage("照片导入:customer_id:"+Tools.processNull(personPhotoId));
			if (this.file != null) {
				File f = this.getFile()[0];
				String str = f.length()/1024 + "";
				BufferedImage bufferedImage = ImageIO.read(f);
				int photoSize = Integer.valueOf(baseService.getSysConfigurationParameters("PHOTO_SIZE"));
				int photoWidth = Integer.valueOf(baseService.getSysConfigurationParameters("PHOTO_WIDTH"));
				int photoHeight = Integer.valueOf(baseService.getSysConfigurationParameters("PHOTO_HEIGHT"));
				int width = bufferedImage.getWidth();
				int height = bufferedImage.getHeight();
				if(Integer.valueOf(str) >= photoSize){
					jsonObject.put("status",1);
					jsonObject.put("errMsg","照片大小不能超过" + photoSize + "KB！");
				} else if (width != photoWidth || height != photoHeight) {
					jsonObject.put("status", 1);
					jsonObject.put("errMsg","照片宽高必须为" + photoWidth + " * " + photoHeight + "像素");
				} else {
					BasePersonal person  = (BasePersonal)basicPhotoService.findOnlyRowByHql("from BasePersonal where customerId='"+personPhotoId+"'");
					if(person != null){
						BasePhoto photo_new = new BasePhoto();
						photo_new.setCustomerId(personPhotoId);
						byte[] ingByte = FileIO.InputStreamToByte(new FileInputStream(f));
						photo_new.setPhotoState("0");
						StringBuffer inoutData = new StringBuffer(actionLog.getInOutData());
						int startIndex = inoutData.indexOf("personPhotoContent");
						int endIndex = inoutData.indexOf(",", startIndex);
						inoutData.delete(startIndex, endIndex);
						actionLog.setInOutData(inoutData.toString());
						basicPhotoService.persistenceBasicPhoto(photo_new,ingByte,actionLog);
						jsonObject.put("errMsg","保存成功");
					}else{
						jsonObject.put("status",1);
						jsonObject.put("errMsg","用户信息不存在！");
					}
				}
			}else if(!Tools.processNull(personPhotoContent).equals("")){
				BASE64Decoder decoder = new BASE64Decoder();
				byte[] bytes = decoder.decodeBuffer(personPhotoContent);
				BasePersonal person  = (BasePersonal)basicPhotoService.findOnlyRowByHql("from BasePersonal where customerId='"+personPhotoId+"'");
				if(person != null){
					BasePhoto photo_new = new BasePhoto();
					photo_new.setCustomerId(personPhotoId);
					photo_new.setPhotoState("0");
					StringBuffer inoutData = new StringBuffer(actionLog.getInOutData());
					int startIndex = inoutData.indexOf("personPhotoContent");
					int endIndex = inoutData.indexOf(",", startIndex);
					inoutData.delete(startIndex, endIndex);
					actionLog.setInOutData(inoutData.toString());
					basicPhotoService.persistenceBasicPhoto(photo_new,bytes,actionLog);
					jsonObject.put("errMsg","保存成功");
				}else{
					jsonObject.put("status",1);
					jsonObject.put("errMsg","用户信息不存在！");
				}
			}else{
				throw new CommonException("请选择上传照片或读取身份证照片！");
			}
		}catch(Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg","照片导入发生错误："+e.getMessage());
		}
		return "jsonObj";
	}
	
	public String fileUpByIDCard(){
		jsonObject.put("status",0);
		jsonObject.put("errMsg",0);
		jsonObject.put("title", "系统消息");
		BASE64Decoder decoder = new BASE64Decoder();
		SysActionLog actionLog = basicPhotoService.getCurrentActionLog();
		actionLog.setDealCode(DealCode.PHOTO_IMPORT_SIGNONE);
		actionLog.setMessage("照片导入:certNo:"+Tools.processNull(certNo));
		actionLog.setInOutData("照片导入:certNo:"+Tools.processNull(certNo));
		try {
			byte[] bytes = decoder.decodeBuffer(personPhotoContent);
			List<BasePersonal> persons  = (List<BasePersonal>)basicPhotoService.findByHql("from BasePersonal where certNo='"+certNo+"'");
			if(persons == null || persons.size()>1){
				throw new CommonException("未查询到客户信息或查询到多个客户信息");
			}
			BasePhoto photo_new = new BasePhoto();
			photo_new.setCustomerId(persons.get(0).getCustomerId().toString());
			basicPhotoService.persistenceBasicPhoto(photo_new,bytes,actionLog);
			jsonObject.put("errMsg","保存成功");
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg","照片导入发生错误："+e.getMessage());
		}
		return "jsonObj";
	}
	
	/**
	 * 
	 */
	
	public String toBatchImpSave(){
		jsonObject.put("status",0);
		jsonObject.put("errMsg",0);
		jsonObject.put("title", "系统消息");
		try {
			if(Tools.processNull(uploadType).equals("")) {
				jsonObject.put("status", 1);
				jsonObject.put("errMsg", "未传入上传类型数据！");
			} else {
				SysActionLog actionLog = basicPhotoService.getCurrentActionLog();
				actionLog.setDealCode(DealCode.PHOTO_IMPORT_ZIPFILE);
				if (this.file != null) {
					File f = this.getFile()[0];
					String str = f.length()/1024/1024 + "";
					int photoZipSize = Integer.valueOf(baseService.getSysConfigurationParameters("PHOTO_ZIP_SIZE"));
					if(Integer.valueOf(str) >= photoZipSize){
						jsonObject.put("status",1);
						jsonObject.put("errMsg","压缩文件过大，不可超过" + photoZipSize + "MB！");
					}
					actionLog.setMessage("批量导入照片");
					basicPhotoService.saveImportPhoto(f, uploadType, actionLog);
					jsonObject.put("errMsg","批量照片导入成功！");
				}
			}
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg","批量照片导入发生错误："+e.getMessage());
		}
		return "jsonObj";
	}

	/**
	 * 照片处理数据上传。
	 * @return
	 */
	public String photoProcessDataUpload() {
		try {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", "");
			SysActionLog sysActionLog = basicPhotoService.getCurrentActionLog();
			sysActionLog.setDealCode(DealCode.PHOTO_IMPORT_SIGNONE);
			sysActionLog.setMessage("照片导入:customer_id:" + Tools.processNull(personPhotoId));
			if (this.file != null) {
				File photoFile = this.getFile()[0];
				Long photoFileSize = photoFile.length() / 1024;
				BufferedImage previousBufferedImage = ImageIO.read(photoFile);
				int photoWidth = Integer.valueOf(baseService.getSysConfigurationParameters("PHOTO_WIDTH"));
				int photoHeight = Integer.valueOf(baseService.getSysConfigurationParameters("PHOTO_HEIGHT"));
				int photoFileMaxSize = Integer.valueOf(baseService.getSysConfigurationParameters("PHOTO_SIZE"));
				BasePersonal basePersonal = (BasePersonal) baseService.findOnlyRowByHql("from BasePersonal b where b.customerId = '" + personPhotoId + "'");
				if (Integer.valueOf(photoFileSize + "") >= photoFileMaxSize) {
					jsonObject.put("errMsg", "照片大小不能超过" + photoFileMaxSize + "KB！");
				} else if (Tools.processNull(photoProcessData).equals("")) {
					jsonObject.put("errMsg", "未获取到照片处理数据！");
				} else if (basePersonal == null) {
					jsonObject.put("errMsg", "人员信息不存在！");
				} else {
					String[] photoProcessDatas = photoProcessData.split("_");
					int x = (int) Math.floor(Float.valueOf(photoProcessDatas[0]));
					int y = (int) Math.floor(Float.valueOf(photoProcessDatas[1]));
					int width = (int) Math.floor(Float.valueOf(photoProcessDatas[2]));
					int height = (int) Math.floor(Float.valueOf(photoProcessDatas[3]));
					int rotate = Integer.valueOf(photoProcessDatas[4]);
					BufferedImage rotateBufferedImage = null;
					// 照片旋转操作
					if (rotate / 90 != 0) {
						if (rotate / 90 == 2) {
							rotateBufferedImage = new BufferedImage(previousBufferedImage.getWidth(), previousBufferedImage.getHeight(), previousBufferedImage.getColorModel().getTransparency());
						} else if (rotate / 90 == 1 || rotate / 90 == 3) {
							rotateBufferedImage = new BufferedImage(previousBufferedImage.getHeight(), previousBufferedImage.getWidth(), previousBufferedImage.getColorModel().getTransparency());
						}
						Graphics2D graphics2d = rotateBufferedImage.createGraphics();
						graphics2d.rotate(Math.toRadians(rotate), previousBufferedImage.getWidth() / 2, previousBufferedImage.getWidth() / 2);
						graphics2d.drawImage(previousBufferedImage, 0, 0, null);
						graphics2d.dispose();
						previousBufferedImage = rotateBufferedImage;
					}
					// 照片缩放裁剪操作
					BufferedImage processBufferedImage = new BufferedImage(photoWidth, photoHeight, previousBufferedImage.getColorModel().getTransparency());
					Graphics2D graphics2d = processBufferedImage.createGraphics();
					graphics2d.drawImage(previousBufferedImage, 0, 0, photoWidth, photoHeight, x, y, x + width, y + height, null);
					graphics2d.dispose();
					BasePhoto basePhoto = new BasePhoto();
					basePhoto.setCustomerId(personPhotoId);
					basePhoto.setPhotoState("0");
					ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
					ImageIO.write(processBufferedImage, "jpg", byteArrayOutputStream);
					byte[] photoByte = byteArrayOutputStream.toByteArray();
					basicPhotoService.persistenceBasicPhoto(basePhoto, photoByte, sysActionLog);
					jsonObject.put("status", 0);
				}
			} else {
				throw new CommonException("请选择您要上传的照片文件！");
			}
		} catch (Exception e) {
			jsonObject.put("errMsg", "照片处理数据上传发生错误：" + e.getMessage());
		}
		return "jsonObj";
	}

	public BasePhoto getModel(){ 
			if (null==basicPhoto)
			{
				basicPhoto =new BasePhoto();
			}
			return basicPhoto;
	}
	
    @Autowired
	public void setBasicPhotoService(BasicPhotoService basicPhotoService )
	{
		this.basicPhotoService = basicPhotoService;
	}
	public String getPersonPhotoId() {
		return personPhotoId;
	}

	public void setPersonPhotoId(String personPhotoId) {
		this.personPhotoId = personPhotoId;
	}

	public File[] getFile() {
		return file;
	}

	public void setFile(File[] file) {
		this.file = file;
	}

	public String[] getFileFileName() {
		return fileFileName;
	}

	public void setFileFileName(String[] fileFileName) {
		this.fileFileName = fileFileName;
	}

	public String[] getFilePath() {
		return filePath;
	}

	public void setFilePath(String[] filePath) {
		this.filePath = filePath;
	}
	
	public BasePhoto getBasicPhoto() {
		return basicPhoto;
	}

	public void setBasicPhoto(BasePhoto basicPhoto) {
		this.basicPhoto = basicPhoto;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}

	public String getPersonPhotoContent() {
		return personPhotoContent;
	}

	public void setPersonPhotoContent(String personPhotoContent) {
		this.personPhotoContent = personPhotoContent;
	}

	public String getUploadType() {
		return uploadType;
	}

	public void setUploadType(String uploadType) {
		this.uploadType = uploadType;
	}

	public String getPhotoProcessData() {
		return photoProcessData;
	}

	public void setPhotoProcessData(String photoProcessData) {
		this.photoProcessData = photoProcessData;
	}
}
