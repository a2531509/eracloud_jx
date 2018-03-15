package com.erp.viewModel;

import java.util.ArrayList;
import java.util.List;
/**
 * 类功能说明 TODO:Exception工具类
 * 类修改者	修改日期
 * 修改说明
 * <p>Title: BaseService.java</p>
 * <p>Description:杰斯科技</p>
 * <p>Copyright: Copyright (c) 2012</p>
 * <p>Company:杰斯科技</p>
 * @author hujc 631410114@qq.com
 * @date 2015-4-1 下午03:18:05
 * @version V1.0
 */
@SuppressWarnings("rawtypes")
public class GridModel {
	private List  rows= new ArrayList();
	private Long total=0L;
	private int status = 0;//表格数据查询状态0 查询成功 1 查询失败
	private String errMsg = "";//表格数据查询失败后的提示信息
	public List getRows() {
		return rows;
	}
	public void setRows(List rows) {
		this.rows = rows;
	}
	public Long getTotal() {
		return total;
	}
	public void setTotal(Long total) {
		this.total = total;
	}
	public int getStatus() {
		return status;
	}
	public void setStatus(int status) {
		this.status = status;
	}
	public String getErrMsg() {
		return errMsg;
	}
	public void setErrMsg(String errMsg) {
		this.errMsg = errMsg;
	}
}
