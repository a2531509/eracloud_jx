package com.erp.daoImpl;

import java.io.Serializable;
import java.sql.CallableStatement;
import java.sql.Clob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import oracle.jdbc.internal.OracleTypes;

import org.hibernate.Query;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.jdbc.ReturningWork;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.dao.PublicDao;
import com.erp.exception.CommonException;
import com.erp.model.BasePhoto;
import com.erp.util.DateUtil;
import com.erp.util.FileIO;
import com.erp.util.ProWork;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

@SuppressWarnings("unchecked")
@Repository("publicDao")
public class PublicDaoImpl<T> implements PublicDao<T> {

	private SessionFactory sessionFactory;

	public SessionFactory getSessionFactory() {
		return sessionFactory;
	}

	public boolean isDebug = false;

	@Autowired
	public void setSessionFactory(SessionFactory sessionFactory) {
		this.sessionFactory = sessionFactory;
	}

	// 注册监听器
	/*
	 * @PostConstruct public void registerListeners() { EventListenerRegistry
	 * registry = ((SessionFactoryImpl)
	 * sessionFactory).getServiceRegistry().getService(EventListenerRegistry.class);
	 * registry.getEventListenerGroup(EventType.POST_COMMIT_INSERT).appendListener(new
	 * PostInsert());
	 * registry.getEventListenerGroup(EventType.POST_COMMIT_UPDATE).appendListener(new
	 * PostUpdate()); }
	 */

	private Session getCurrentSession() {
		return sessionFactory.getCurrentSession();
	}

	public Object merge(Object o) throws CommonException {
		Object serializable = this.getCurrentSession().merge(o);
		return serializable;
	}

	public Serializable save(Object o) throws CommonException {
		Serializable serializable = null;
		try {
			serializable = this.getCurrentSession().save(o);
			this.getCurrentSession().flush();
		} catch (Exception e) {
			e.printStackTrace();
			throw new CommonException(e.getMessage());
		}
		return serializable;
	}

	public void delete(Object o) throws CommonException {
		try {
			this.getCurrentSession().delete(o);
			this.getCurrentSession().flush();
		} catch (Exception e) {
			throw new CommonException("delete "
					+ o.getClass().getCanonicalName() + " bean erron" + e);
		}

	}

	public void update(Object o) throws CommonException {
		try {
			this.getCurrentSession().update(o);
			this.getCurrentSession().flush();
		} catch (Exception e) {
			throw new CommonException("update "
					+ o.getClass().getCanonicalName() + " bean error" + e);
		}

	}

	public void deleteToUpdate(Object o) throws CommonException {
		try {
			this.getCurrentSession().update(o);
			this.getCurrentSession().flush();
		} catch (Exception e) {
			throw new CommonException("update "+ o.getClass().getCanonicalName() + " bean error" + e);
		}

	}

	public void saveOrUpdate(Object o) throws CommonException {
		try {
			this.getCurrentSession().saveOrUpdate(o);
			this.getCurrentSession().flush();
		} catch (Exception e) {
			throw new CommonException("saveOrUpdate "
					+ o.getClass().getCanonicalName() + " bean error" + e);
		}
	}

	public List<T> find(String hql) throws CommonException {
		List<T> list = null;
		try {
			list = this.getCurrentSession().createQuery(hql).list();
			
		} catch (Exception e) {
			e.printStackTrace();
			throw new CommonException("findByHql :" + hql + "  error" + e);
		}
		return list;
	}

	@SuppressWarnings("rawtypes")
	public List findBySQL(String sql) throws CommonException {
		List<T> list = null;
		try {
			list = this.getCurrentSession().createSQLQuery(sql).list();
		} catch (Exception e) {
			throw new CommonException("findBySQL :" + sql + "  error" + e);
		}
		return list;
	}

	public List<T> findSQL(String sql, Map<String, Object> params,
			Integer page, Integer rows) throws CommonException {
		if (page == null || page < 1) {
			page = 1;
		}
		if (rows == null || rows < 1) {
			rows = 10;
		}
		Query q = this.getCurrentSession().createSQLQuery(sql);
		return q.setFirstResult((page - 1) * rows).setMaxResults(rows).list();
	}

	public List<T> find(String hql, Map<String, Object> params)
			throws CommonException {
		Query q = this.getCurrentSession().createQuery(hql);
		if (params != null && !params.isEmpty()) {
			for (String key : params.keySet()) {
				q.setParameter(key, params.get(key));
			}
		}
		return q.list();
	}

	public List<T> find(String hql, Map<String, Object> params, Integer page,
			Integer rows) throws CommonException {
		if (page == null || page < 1) {
			page = 1;
		}
		if (rows == null || rows < 1) {
			rows = 10;
		}
		Query q = this.getCurrentSession().createQuery(hql);
		if (params != null && !params.isEmpty()) {
			for (String key : params.keySet()) {
				q.setParameter(key, params.get(key));
			}
		}
		return q.setFirstResult((page - 1) * rows).setMaxResults(rows).list();
	}
	

	public T get(Class<T> c, Serializable id) throws CommonException {
		return (T) this.getCurrentSession().get(c, id);
	}

	public T get(String hql, Map<String, Object> param) throws CommonException {
		List<T> l = this.find(hql, param);
		if (l != null && l.size() > 0) {
			return l.get(0);
		} else {
			return null;
		}
	}

	public Long count(String hql) throws CommonException {
		return (Long) this.getCurrentSession().createQuery(hql).uniqueResult();
	}

	public Long countSql(String sql) throws CommonException {
		Query q = this.getCurrentSession().createSQLQuery(sql);
		return Long.parseLong(q.uniqueResult().toString());
	}

	public Long count(String hql, Map<String, Object> params)
			throws CommonException {
		Query q = this.getCurrentSession().createQuery(hql);
		if (params != null && !params.isEmpty()) {
			for (String key : params.keySet()) {
				q.setParameter(key, params.get(key));
			}
		}
		return (Long) q.uniqueResult();
	}

	public Integer executeHql(String hql) throws CommonException {
		return this.getCurrentSession().createQuery(hql).executeUpdate();
	}

	public Integer executeHql(String hql, Map<String, Object> params)
			throws CommonException {
		Query q = this.getCurrentSession().createQuery(hql);
		if (params != null && !params.isEmpty()) {
			for (String key : params.keySet()) {
				q.setParameter(key, params.get(key));
			}
		}
		return q.executeUpdate();
	}

	public Serializable savePhotoImg(BasePhoto basePhoto, byte[] filebyte)
			throws CommonException {
		basePhoto.setPhoto(this.getCurrentSession().getLobHelper().createBlob(filebyte));
		Serializable serializable = this.getCurrentSession().save(basePhoto);
		this.getCurrentSession().flush();
		return serializable;
	}

	public void updatePhotoImg(BasePhoto basePhoto, byte[] filebyte)
			throws CommonException {
		basePhoto.setPhoto(this.getCurrentSession().getLobHelper().createBlob(filebyte));
		this.getCurrentSession().update(basePhoto);
		this.getCurrentSession().flush();
	}

	public Date getDateBaseTime() throws CommonException {
		List list = findBySQL("select to_char(sysdate,'yyyy-mm-dd HH24:mi:ss') from dual");
		return DateUtil.formatDateTime((list.get(0).toString()));
	}
	public String getDateBaseTimeStr() throws CommonException {
		List list = findBySQL("select to_char(sysdate,'yyyy-mm-dd HH24:mi:ss') from dual");
		return list.get(0).toString();
	}

	public Date getDateBaseDate() throws CommonException {
		List list = findBySQL("select to_char(sysdate,'yyyy-mm-dd') from dual");
		return DateUtil.formatDate((list.get(0).toString()));
	}

	@Override
	public int doSql(String sql) throws CommonException {
		int result =0;
		try {
			SQLQuery query = this.getCurrentSession().createSQLQuery(sql);
			result = query.executeUpdate();
			this.getCurrentSession().flush();
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
		return result;
		

	}

	@Override
	public Object findOnlyFieldBySql(String sql) throws CommonException {
		try {
			SQLQuery q = this.getCurrentSession().createSQLQuery(sql);
			if (q == null) {
				return null;
			}
			if (q.list() != null && q.list().size() > 0) {
				return q.list().get(0);
			} else {
				return null;
			}
		} catch (Exception e) {
            throw new CommonException(e.getMessage());
		}
	}

	@Override
	public String findTrCodeNameByCodeType(Integer codeValue)
			throws CommonException {
		String sql = "select deal_code_name from SYS_CODE_TR where  deal_code="
				+ codeValue;
		return (String) findOnlyFieldBySql(sql);
	}

	@Override
	public List callProc(String proc, List<Object> inParamList,
			List<Object> outParamList) throws CommonException {
		SQLQuery query;
		List list = null;
		try {
			String procName = "call " + proc + "(";
			if (inParamList != null && inParamList.size() > 0) {
				for (int i = 0; i < inParamList.size(); i++) {
					procName += "?,";
				}
			}
			if (outParamList != null && outParamList.size() > 0) {
				for (int k = 0; k < outParamList.size(); k++) {
					if (k != outParamList.size() - 1) {
						procName += "?,";
					} else {
						procName += "?";
					}

				}
			} else {
				procName = procName.substring(0, procName.length() - 1);
			}
			procName += ")";
			ProWork r = new ProWork(procName, inParamList, outParamList) {
				public void execute(Connection connection) {
					ResultSet rs = null;
					CallableStatement call;
					try {
						call = connection.prepareCall("{" + this.getProSql()
								+ "}");
						Integer outStart = 0;
						if (this.getInList() != null
								&& this.getInList().size() > 0) {
							outStart = outStart + this.getInList().size() + 1;
							for (int i = 0; i < this.getInList().size(); i++) {
								call.setString(i + 1, this.getInList().get(i)
										.toString());
							}
						}
						if (this.getInList() != null
								&& this.getInList().size() > 0) {
							for (int j = 0; j < this.getOutList().size(); j++) {
								call.registerOutParameter(j + outStart, Integer
										.valueOf(this.getOutList().get(j)
												.toString()));
							}
						}
						call.executeUpdate();
						List listret = new ArrayList();
						for (int k = 0; k < this.getOutList().size(); k++) {
							if (this.getOutList().get(k).equals(Types.VARCHAR)) {
								listret.add(call.getString(k + outStart));
							} else if (this.getOutList().get(k).equals(
									Types.INTEGER)) {
								listret.add(call.getInt(k + outStart));
							} else if (this.getOutList().get(k).equals(
									Types.JAVA_OBJECT)) {
								listret.add(resultSetToList((ResultSet) call
										.getObject(k + outStart)));
							} else {
								throw new CommonException("传入的存储过程参数无法转化");
							}

						}
						this.setReturnList(listret);
					} catch (SQLException e) {
						e.printStackTrace();
					}

				}
			};
			this.getCurrentSession().doWork(r);
			list = r.getReturnList();
		} catch (Exception e) {
			throw new CommonException("execute :" + proc + "  error" + e.getMessage());
		}
		return list;
	}

	public List resultSetToList(ResultSet rs) throws java.sql.SQLException {
		if (rs == null)
			return Collections.EMPTY_LIST;
		ResultSetMetaData md = rs.getMetaData(); // 得到结果集(rs)的结构信息，比如字段数、字段名等
		int columnCount = md.getColumnCount(); // 返回此 ResultSet 对象中的列数
		List list = new ArrayList();
		Map rowData = new HashMap();
		while (rs.next()) {
			rowData = new HashMap(columnCount);
			for (int i = 1; i <= columnCount; i++) {
				rowData.put(md.getColumnName(i), rs.getObject(i));
			}
			list.add(rowData);
			System.out.println("list:" + list.toString());
		}
		for (int j = 0; j < list.size(); j++) {
			System.out.println("list:" + list.get(j).toString());
		}
		return list;
	}

	public Page pagingQuery(final String sql, final Integer pageNum,
			final Integer pageSize) throws Exception {
		try {
			Session session = this.getCurrentSession();
			JSONObject rs = session
					.doReturningWork(new ReturningWork<JSONObject>() {
						public JSONObject execute(Connection conn)
								throws SQLException {
							String call = "{ call zpage.page(?,?,?,?,?,?,?,?)}";
							CallableStatement stat = conn.prepareCall(call);
							stat.setString(1, sql);
							stat.setInt(2, pageNum);
							stat.setInt(3, pageSize);
							stat.registerOutParameter(4, OracleTypes.NUMBER);
							stat.registerOutParameter(5, OracleTypes.NUMBER);
							stat.registerOutParameter(6, OracleTypes.CURSOR);
							stat.registerOutParameter(7, OracleTypes.VARCHAR);
							stat.registerOutParameter(8, OracleTypes.VARCHAR);
							stat.execute();
							JSONObject allData = new JSONObject();
							JSONObject asMsg = new JSONObject();
							asMsg.put("isSuc", stat.getString(7));
							asMsg.put("outMsg", stat.getString(8));
							asMsg.put("totalCount", stat.getInt(4));
							asMsg.put("totalPages", stat.getInt(5));
							allData.put("msg", asMsg);
							JSONArray allRs = new JSONArray();
							if (Tools.processNull(stat.getString(7))
									.equals("0")) {
								ResultSet rs = (ResultSet) stat.getObject(6);
								ResultSetMetaData mta = rs.getMetaData();
								int cnumcount = mta.getColumnCount();
								while (rs.next()) {
									JSONObject temprow = new JSONObject();
									for (int cnum = 1; cnum <= cnumcount; cnum++) {
										temprow.put(mta.getColumnLabel(cnum),
												Tools.processNull(
														rs.getObject(cnum))
														.toString());
									}
									allRs.add(temprow);
								}
								allData.put("allRs", allRs);
								if (isDebug) {
									StringBuffer sb = new StringBuffer();
									sb.append("[[\r\n");
									for (int i = 1; i <= cnumcount; i++) {
										sb.append("\t{field:'");
										sb.append(mta.getColumnLabel(i));
										sb
												.append("',title:'',sortable:true},\r\n");
									}
									sb = sb.deleteCharAt(sb.length() - 3);
									sb.append("]]");
									System.out.println(sb.toString());
								}
							} else {
								allData.put("allRs", null);
							}
							return allData;
						}
					});
			if (rs == null) {
				throw new Exception("执行出现错误，未获取到执行返回结果！");
			}
			if (rs.getJSONObject("msg").getString("isSuc").equals("-1")) {
				throw new Exception(rs.getJSONObject("msg").getString("outMsg"));
			}
			Page page = new Page();
			page.setAllRs(rs.getJSONArray("allRs"));
			page
					.setTotalCount(rs.getJSONObject("msg").getInteger(
							"totalCount"));
			page
					.setTotalPages(rs.getJSONObject("msg").getInteger(
							"totalPages"));
			return page;
		} catch (Exception e) {
			throw e;
		}
	}

	@Override
	public ResultSet findResultSet(final String sql) throws Exception {
		try {
			ResultSet resultSet1 = this.getCurrentSession().doReturningWork(
					new ReturningWork<ResultSet>() {
						@Override
						public ResultSet execute(Connection connection)
								throws SQLException {
							PreparedStatement preparedStatement = connection
									.prepareStatement(sql);
							ResultSet resultSet = preparedStatement
									.executeQuery();
							return resultSet;
						}
					});
			return resultSet1;
		} catch (Exception e) {
			throw e;
		}
	}

	/**
	 * 通过SQL查询出来结果返回MAP对象
	 * 
	 * @param sql
	 * @return
	 * @throws CommonException
	 */
	public List findBySql_Map(String sql) throws CommonException {
		List list = new ArrayList();
		try {
			ResultSet rs = findResultSet(sql);
			ResultSetMetaData rsmd = rs.getMetaData();
			int colCount = rsmd.getColumnCount();
			HashMap hm;
			for (; rs.next(); list.add(hm)) {
				hm = new HashMap();
				for (int i = 1; i <= colCount; i++) {
					String fieldName = rsmd.getColumnName(i);
					Object fieldValue = rs.getObject(fieldName);
					if (rsmd.getColumnType(i) == 12 && fieldValue == null){
						fieldValue = "";
					}else if (rsmd.getColumnType(i) == 2005&& fieldValue != null) {
						Clob clob = (Clob) fieldValue;
						fieldValue = clob.getSubString(1L, (int) clob.length());
					}
					hm.put(fieldName.toLowerCase(), fieldValue);
				}

			}

			// con.close();
		} catch (Exception e) {
			throw new CommonException((new StringBuilder(
					"the findBySql_Map Method in ")).append(
					getClass().getName()).append(" occur error: ").append(
					e.getMessage()).toString());
		} catch (Throwable e) {
			throw new CommonException((new StringBuilder(
					"the findBySql_Map Method in ")).append(
					getClass().getName()).append(" occur error: ").append(
					e.getMessage()).toString());
		}
		return list;
	}

	protected void ss(String sql, int size) {
		try {
			if (size > 4999) {
				List list = new ArrayList();
				list.add((new StringBuilder(String.valueOf(DateUtil
						.getNowTime()))).append("---当前查询返回").append(size)
						.append("条记录，可能存在性能问题，其执行脚本为：").toString());
				list.add(sql);
				FileIO.AppendedToTheFile("zt_Optimization.log", list);
			}
		} catch (Exception exception) {
		}
	}
	/**
	 * 查询多个对象
	 * @param hql
	 * @param params
	 * @param page
	 * @param rows
	 * @return
	 * @throws CommonException
	 */
	public List<Object[]> queryForPageByHql(String hql, Map<String, Object> params,Integer page,Integer rows)throws CommonException {
		if (page == null || page < 1) {
			page = 1;
		}
		if (rows == null || rows < 1) {
			rows = 10;
		}
		Query q = this.getCurrentSession().createQuery(hql);
		if (params != null && !params.isEmpty()) {
			for (String key : params.keySet()) {
				q.setParameter(key, params.get(key));
			}
		}
		return q.setFirstResult((page - 1) * rows).setMaxResults(rows).list();
	}
	/**
	 * 取时间的
	 */
	public String getDateBaseTimeStr(String format)
			throws CommonException{
			return DateUtil.formatDate(getDateBaseTime(), format);
	}
}
