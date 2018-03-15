package com.erp.action;


import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.springframework.beans.factory.annotation.Autowired;

import com.erp.model.BaseCity;
import com.erp.model.BaseRegion;
import com.erp.model.BaseTown;
import com.erp.service.CityRegionTownService;
import com.erp.util.Tools;


/**
 * 类功能说明 TODO: 城市区域街道下拉框处理按钮action
 * 类修改者
 * 修改日期
 * 修改说明
 * <p>Title: FunctionAction.java</p>
 * <p>Description:杰斯科技</p>
 * <p>Copyright: Copyright (c) 2006</p>
 * <p>Company:杰斯科技有限公司</p>
 * @author hujc 631410114@qq.com
 * @date 2015-4-5 下午4:50:56
 * @version V1.0
 */
@Namespace("/cityRegionTown")
@Action(value = "cityRegionTownAction")
public class CityRegionTownAction extends BaseAction {
	
	private static final long serialVersionUID = -294618203661974490L;
	private CityRegionTownService cityRegionTownService;
	@Autowired
	public void setCityRegionTownService(CityRegionTownService cityRegionTownService )
	{
		this.cityRegionTownService = cityRegionTownService;
	}
	private BaseCity baseCity;
	
	private BaseRegion baseRegion;
	
	private BaseTown baseTown;
	
	public BaseCity getBaseCity() {
		return baseCity;
	}

	public void setBaseCity(BaseCity baseCity) {
		this.baseCity = baseCity;
	}

	public BaseRegion getBaseRegion() {
		return baseRegion;
	}

	public void setBaseRegion(BaseRegion baseRegion) {
		this.baseRegion = baseRegion;
	}

	public BaseTown getBaseTown() {
		return baseTown;
	}

	public void setBaseTown(BaseTown baseTown) {
		this.baseTown = baseTown;
	}
	private String cityCode;
	private String regionCode;
	
	
	public String getCityCode() {
		return cityCode;
	}

	public void setCityCode(String cityCode) {
		this.cityCode = cityCode;
	}

	public String getRegionCode() {
		return regionCode;
	}

	public void setRegionCode(String regionCode) {
		this.regionCode = regionCode;
	}

	private  String cityId;
	private  String regionId;
	private  String townId;
	
	public String getCityId() {
		return cityId;
	}

	public void setCityId(String cityId) {
		this.cityId = cityId;
	}

	public String getRegionId() {
		return regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	public String getTownId() {
		return townId;
	}

	public void setTownId(String townId) {
		this.townId = townId;
	}

	/**  
	* 函数功能说明 
	* hujc修改者名字
	* 2013-6-24修改日期
	* 修改内容
	* @Title: findAllCity 
	* @Description: TODO:查询城市代码
	* @param @return
	* @param @throws Exception    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public String findAllCity() throws Exception
	{
		OutputJson(cityRegionTownService.findAllCity());
		return null;
	}
	
	
	/**  
	* 函数功能说明 
	* hujc修改者名字
	* 2013-6-24修改日期
	* 修改内容
	* @Title: findSystemCodeByType 
	* @Description: TODO:查询城市代码
	* @param @return
	* @param @throws Exception    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public String findCityByCityId() throws Exception
	{
		String para1 = (String)ServletActionContext.getRequest().getAttribute("cityId");
		OutputJson(cityRegionTownService.findBasicAreaCityByCityId(para1));
		return null;
	}
	
	/**  
	* 函数功能说明 
	* hujc修改者名字
	* 2013-6-24修改日期
	* 修改内容
	* @Title: findAllRegionByCity 
	* @Description: TODO:查询区域的方法
	* @param @return
	* @param @throws Exception    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public String findAllRegionByCity() throws Exception
	{
		String para1 = (String)ServletActionContext.getRequest().getAttribute("cityCode");
		if(Tools.processNull(para1).equals("")){
			para1="314000";
		}
		OutputJson(cityRegionTownService.findAllRegionByCity(para1));
		return null;
	}
	
	
	/**  
	* 函数功能说明 
	* hujc修改者名字
	* 2013-6-24修改日期
	* 修改内容
	* @Title: findAllRegionByCity 
	* @Description: TODO:查询区域的方法
	* @param @return
	* @param @throws Exception    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public String findRegionByRegionId() throws Exception
	{
		String para1 = (String)ServletActionContext.getRequest().getAttribute("regionId");
		OutputJson(cityRegionTownService.findBasicAreaRegionByRegionId(para1));
		return null;
	}
	
	/**  
	* 函数功能说明 
	* hujc修改者名字
	* 2013-6-24修改日期
	* 修改内容
	* @Title: findAllTownByRegion 
	* @Description: TODO:查询乡镇街道的地址
	* @param @return
	* @param @throws Exception    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public String findAllTownByRegion() throws Exception
	{
		String para1 = (String)ServletActionContext.getRequest().getAttribute("regionCode");
		OutputJson(cityRegionTownService.findAllTownByRegion(para1));
		return null;
	}
	
	/**  
	* 函数功能说明 
	* hujc修改者名字
	* 2013-6-24修改日期
	* 修改内容
	* @Title: findAllTownByRegion 
	* @Description: TODO:查询乡镇街道的地址
	* @param @return
	* @param @throws Exception    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public String findTownByTownId() throws Exception
	{
		String para1 = (String)ServletActionContext.getRequest().getAttribute("townId");
		OutputJson(cityRegionTownService.findBasicAreaTownByTownId(para1));
		return null;
	}
	/**
	 * 获取所有的comm
	 */
	public String findAllCommByTownId(){
		String para1 = (String)ServletActionContext.getRequest().getAttribute("townCode");
		OutputJson(cityRegionTownService.findAllCommByTown(para1));
		return null;
	}

	
}
