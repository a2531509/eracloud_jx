<%--
  Created by IntelliJ IDEA.
  User: yangn
  Date: 2016-09-12
  Time: 10:54:35
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript">
	var $gridview;
	$(function(){
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
			to:10
		},"name");
		$.autoComplete({
			id:"name",
			text:"name",
			value:"cert_no",
			table:"base_personal",
			keyColumn:"name",
			minLength:1,
			to:10
		},"certNo");
		$gridview = createDataGrid({
			id:"dgview",
			url:"cardapply/cardApplyAction!toViewJrsbkImportData.action?rec.dealNo=${param.dealNo}",
			border:false,
			fit:true,
			singleSelect:true,
			queryParams:{queryType:"0"},
			scrollbarSize:0,
			pageSize:100,
			toolbar:"#tbview",
		    fitColumns:false,
		    pageList:[50,100,200,300,500],
		    frozenColumns:[[
				{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"REGION_ID",title:"统筹区编码",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"REGION_NAME",title:"统筹区名称",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"BANK_ID",title:"银行编码",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"BANK_NAME",title:"银行名称",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"RECV_BRCH_ID",title:"领卡网点编码",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"FULL_NAME",title:"领卡网点名称",sortable:true}        
		    ]],
	    	columns:[[
				{field:"TASK_ID",title:"任务编号",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"TASK_NAME",title:"任务名称"},
				{field:"APPLYTYPE",title:"申领类型",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"STATETYPE",title:"状态",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
					if(dealNull(row.DEAL_STATE) == "1"){
						return "<span style='color:red'>" + value + "</span>";
					}else{
						return value;
					}
				}},
				{field:"DEAL_MSG",title:"备注",width:parseInt($(this).width() * 0.12)}
			]]
		});
	});
	function toQueryTaskList(){
		var params = getformdata("viewSearchConts");
		params["queryType"] = "0";
		params["bp.name"] = $("#name").val();
		params["bp.certNo"] = $("#certNo").val();
		$gridview.datagrid("load",params);
	}
</script>
<n:layout>
	<n:center cssStyle="border:none">
		<div id="tbview">
			<form id="viewSearchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft" style="width:10%;">证件号码：</td>
						<td class="tableright" style="width:20%;"><input id="certNo" name="bp.certNo" type="text" class="textinput" maxlength="18"/></td>
						<td class="tableleft" style="width:10%;">姓名：</td>
						<td class="tableright" style="width:20%;"><input id="name" name="bp.name" type="text" class="textinput" maxlength="15"/></td>
						<td class="tableright" colspan="2">
							<a data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="toQueryTaskList()">查询</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
	  	<table id="dgview"></table>
	</n:center>
</n:layout>