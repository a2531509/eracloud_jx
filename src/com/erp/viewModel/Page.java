/**
 * 
 */
package com.erp.viewModel;

import com.alibaba.fastjson.JSONArray;


/**
 * @author Administrator
 *
 */
public class Page {
	private Integer totalCount = 0;
	private Integer totalPages = 0;
	private JSONArray allRs = new JSONArray();
	public Integer getTotalCount() {
		return totalCount;
	}
	public void setTotalCount(Integer totalCount) {
		this.totalCount = totalCount;
	}
	public Integer getTotalPages() {
		return totalPages;
	}
	public void setTotalPages(Integer totalPages) {
		this.totalPages = totalPages;
	}
	public JSONArray getAllRs() {
		return allRs;
	}
	public void setAllRs(JSONArray allRs) {
		this.allRs = allRs;
	}
	
	
}
