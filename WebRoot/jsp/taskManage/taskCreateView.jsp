<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript">
	var $gridview;
	var selectIdView = decodeURI("${param.selectIds}").replace(/%/g,"|");
	$(function(){
		$gridview = createDataGrid({
			id:"dgview",
			url:"taskManagement/taskManagementAction!viewCardApply.action?selectIds=" + decodeURI(selectIdView),
			border:false,
			fit:true,
			fitColumns:true,
			singleSelect:false,
			pageSize:20,
			queryParams:{queryType:"0"},
			scrollbarSize:0,
			columns:[[
			   // {field:"SELECTID",checkbox:true},
				{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"NAME",title:"姓名",sortable:true,width : parseInt($(this).width() * 0.1)},
				{field:"GENDER",title:"性别",sortable:true,width:parseInt($(this).width()*0.05)},
				{field:"CERT_TYPE",title:"证件类型",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.15)},
				{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.15)},
				{field:"SUB_CARD_NO",title:"社保卡卡号",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"APPLYWAY",title:"申领方式",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"APPLYTYPE",title:"申领类型",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"APPLYDATE",title:"申领时间",sortable:true,width:parseInt($(this).width()*0.12)},
			]],
			toolbar:"#tbview"
		});
	});
	function toQueryCardApply(){
		var params = getformdata("viewSearchConts");
		params["queryType"] = "0";
		params["taskList.name"] = $("#name").val();
		$gridview.datagrid("load",params);
	}
</script>
<n:layout>
	<n:center cssStyle="border:none">
		<div id="tbview">
			<form id="viewSearchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft" style="width:7%;">姓名：</td>
						<td class="tableright" style="width:18%;"><input id="name" name="taskList.name" type="text" class="textinput" maxlength="15"/></td>
						<td class="tableleft" style="width:7%;">证件号码：</td>
						<td class="tableright" style="width:18%;"><input id="certNo" name="taskList.certNo" type="text" class="textinput" maxlength="18"/></td>
						<td class="tableleft" style="width:7%;">卡号：</td>
						<td class="tableright" style="width:18%;"><input id="cardNo" name="taskList.cardNo" type="text" class="textinput" maxlength="20"/></td>
						<td class="tableright" colspan="1">
							<a data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="toQueryCardApply()">查询</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
	  	<table id="dgview" title=""></table>
	</n:center>
</n:layout>