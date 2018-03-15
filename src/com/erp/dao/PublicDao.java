/**   
* @Title: PublicDao.java TODO:
* @Package com.erp.dao
* @Description: TODO
* @author chenguang 
* @date 2015-4-1 上午08:40:54
* @version V1.0   
*/
package com.erp.dao;

import java.io.Serializable;
import java.sql.ResultSet;
import java.util.Date;
import java.util.List;
import java.util.Map;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.BasePhoto;
import com.erp.viewModel.Page;

/**
 * 类功能说明 TODO:公用dao接口
 * 类修改者	修改日期
 * 修改说明
 * <p>Title: PublicDao.java</p>
 * <p>Description:杰斯科技</p>
 * <p>Copyright: Copyright (c) 2012</p>
 * <p>Company:杰斯科技</p>
 * @author hujc 631410114@qq.com
 * @date 2015-4-1 上午08:40:54
 * @version V1.0
 */
public interface PublicDao<T>
{
	/**
	 * @return  
	* @Title: save 
	* @Description: TODO:保存一个对象
	* @param @param o
	* @param @return    设定文件 
	* @return Serializable    返回类型 
	* @throws 
	*/
	public Serializable save(T o) throws CommonException;
	
	/**
	 * @return  
	* @Title: merge 
	* @Description: TODO:保存一个对象
	* @param @param o
	* @param @return    设定文件 
	* @return Serializable    返回类型 
	* @throws 
	*/
	public Object merge(T o) throws CommonException;
	/** 
	* @Title: delete 
	* @Description: TODO:删除一个对象
	* @param @param o    设定文件 
	* @return void    返回类型 
	* @throws 
	*/
	
	
	public void delete(T o)throws CommonException;

	/** 
	* @Title: update 
	* @Description: TODO:更新一个对象
	* @param @param o    设定文件 
	* @return void    返回类型 
	* @throws 
	*/
	public void update(T o)throws CommonException;

	/**
	 * @return  
	* @Title: save 
	* @Description: TODO:对于照片的表的特殊保存操作
	* @param @param o
	* @param @return    设定文件 
	* @return Serializable    返回类型 
	* @throws 
	*/
	public Serializable savePhotoImg(BasePhoto photo,byte[] filebyte) throws CommonException;
	
	/**
	 * @return  
	* @Title: save 
	* @Description: TODO:对于照片的表的特殊保存操作
	* @param @param o
	* @param @return    设定文件 
	* @return Serializable    返回类型 
	* @throws 
	*/
	public void updatePhotoImg(BasePhoto photo,byte[] filebyte)throws CommonException;

	/** 
	* @Title: saveOrUpdate 
	* @Description: TODO:保存或更新对象
	* @param @param o    设定文件 
	* @return void    返回类型 
	* @throws 
	*/
	
	
	public void saveOrUpdate(T o) throws CommonException;

	/** 
	* @Title: find 
	* @Description: TODO:查询
	* @param @param hql
	* @param @return    设定文件 
	* @return List<T>    返回类型 
	* @throws 
	*/
	public List<T> find(String hql) throws CommonException;

	/** 
	* @Title: get 
	* @Description: TODO:获得一个对象
	* @param @param c
	* @param @param id
	* @param @return    设定文件 
	* @return T    返回类型 
	* @throws 
	*/
	public T get(Class<T> c, Serializable id) throws CommonException;

	/** 
	* @Title: count 
	* @Description: TODO:select count(*) from 类
	* @param @param hql
	* @param @return    设定文件 
	* @return Long    返回类型 
	* @throws 
	*/
	public Long count(String hql) throws CommonException;

	/** 
	* @Title: executeHql 
	* @Description: TODO:执行HQL语句
	* @param @param hql
	* @param @return    设定文件 响应数目
	* @return Integer    返回类型 
	* @throws 
	*/
	public Integer executeHql(String hql) throws CommonException;

	/** 
	* @Title: find 
	* @Description: TODO:查询集合
	* @param @param hql
	* @param @param params
	* @param @return    设定文件 
	* @return List<T>    返回类型 
	* @throws 
	*/
	List<T> find(String hql, Map<String, Object> params) throws CommonException;

	/** 
	* @Title: find 
	* @Description: TODO:查询分页集合
	* @param @param hql
	* @param @param params
	* @param @param page
	* @param @param rows
	* @param @return    设定文件 
	* @return List<T>    返回类型 
	* @throws 
	*/
	List<T> find(String hql, Map<String, Object> params, Integer page,
			Integer rows) throws CommonException;

	/** 
	* @Title: get 
	* @Description: TODO:根据参数查询实体类
	* @param @param hql
	* @param @param param
	* @param @return    设定文件 
	* @return T    返回类型 
	* @throws 
	*/
	T get(String hql, Map<String, Object> param) throws CommonException;

	/** 
	* @Title: count 
	* @Description: TODO:根据参数查询集合条数
	* @param @param hql
	* @param @param params
	* @param @return    设定文件 
	* @return Long    返回类型 
	* @throws 
	*/
	Long count(String hql, Map<String, Object> params) throws CommonException;
	
	/** 
	* @Title: count 
	* @Description: TODO:根据参数查询集合条数
	* @param @param hql
	* @param @param params
	* @param @return    设定文件 
	* @return Long    返回类型 
	* @throws 
	*/
	Long countSql(String sql) throws CommonException;

	/** 
	* @Title: executeHql 
	* @Description: TODO:批量执行HQL (更新) 响应数目
	* @param @param hql
	* @param @param params
	* @param @return    设定文件 
	* @return Integer    返回类型 
	* @throws 
	*/
	Integer executeHql(String hql, Map<String, Object> params) throws CommonException;
	
	/** 
	* @Title: findBySQL 
	* @Description: TODO:按照sql语句查询列表
	* @param @param sql
	* @param @param params
	* @param @return    设定文件 
	* @return Integer    返回类型 
	* @throws 
	*/
	@SuppressWarnings("rawtypes")
	List findBySQL(String sql) throws CommonException;

	/** 
	* @Title: findSQL 
	* @Description: TODO:按照sql语句查询列表 按照指定条件分页
	* @param @param sql
	* @param @param params
	* @param @return    设定文件 
	* @return Integer    返回类型 
	* @throws 
	*/
	public List<T> findSQL(String sql, Map<String, Object> params, Integer page, Integer rows) throws CommonException; 
	
	/** 
	* @Title: deleteToUpdate 
	* @Description: TODO:删除或修改指定对象
	* @param @param sql
	* @param @param params
	* @param @return    设定文件 
	* @return Integer    返回类型 
	* @throws 
	*/
	void deleteToUpdate(T o ) throws CommonException;
	
	/** 
	* @Title: getDateBaseTime 
	* @Description: TODO:获取数据库时间 yyyy-mm-dd hh24:mi:ss
	* @param @param 
	* @param @param params
	* @param @return    设定文件 
	* @return Integer    返回类型 
	* @throws 
	*/
	public Date getDateBaseTime() throws CommonException;
	
	/** 
	* @Title: getDateBaseTime 
	* @Description: TODO:获取数据库时间 yyyy-mm-dd hh24:mi:ss
	* @param @param 
	* @param @param params
	* @param @return    设定文件 
	* @return Integer    返回类型 
	* @throws 
	*/
	public String getDateBaseTimeStr() throws CommonException;
	
	/** 
	* @Title: getDateBaseDate 
	* @Description: TODO:获取数据库日期yyyy-mm-dd
	* @param @param 
	* @param @param params
	* @param @return    设定文件 
	* @return Integer    返回类型 
	* @throws 
	*/
	public Date getDateBaseDate() throws CommonException;
	
	/** 
	* @Title: doSql 
	* @Description: TODO:执行sql语句
	* @param @param sql
	* @param @param params
	* @param @return    设定文件 
	* @return Integer    返回类型 
	* @throws 
	*/
	public int doSql(String sql) throws CommonException;
	
	/** 
	* @Title: findOnlyFieldBySql 
	* @Description: TODO:获取指定的值 精确查找
	* @param sql
	* @param @return    设定文件 
	* @return Integer    返回类型 
	* @throws 
	*/
	public Object findOnlyFieldBySql(String sql) throws CommonException;
	
	/** 
	* @Title: findTrCodeNameByCodeType 
	* @Description: TODO:获取指定的值 精确查找
	* @param sql
	* @param @return    设定文件 
	* @return Integer    返回类型 
	* @throws 
	*/
	public String findTrCodeNameByCodeType(Integer codeValue) throws CommonException;
	
	/**
	 * 调用存储
	 * @param proc
	 * @param paramList
	 * @return
	 * @throws CommonException
	 */
	public List callProc( String proc, List<Object> inParamList,List<Object> outParamList) throws CommonException;
	/**
	 * 分页查询
	 * @param sql
	 * @param pageNum
	 * @param pageSize
	 * @return
	 * @throws Exception
	 */
	public Page pagingQuery(final String sql,final Integer pageNum,final Integer pageSize) throws Exception;
	/**
	 * 取时间的
	 * @param s
	 * @return
	 * @throws CommonException
	 */
	public abstract String getDateBaseTimeStr(String s)throws CommonException;
	
	public ResultSet findResultSet(String sql)throws Exception;
	
	/**
	 * 查询多个对象结果集
	 * @param hql
	 * @param params
	 * @param page
	 * @param rows
	 * @return
	 * @throws CommonException
	 */
	public List<Object[]> queryForPageByHql(String hql, Map<String, Object> params,Integer page,Integer rows)throws CommonException; 

}
