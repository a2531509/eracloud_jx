<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var isReloadGrid = false;
	var $grid;
	$(function() {
		createCustomSelect({
			id:"bankId",
			value:"bank_id",
			text:"bank_name",
			table:"base_bank",
			where:"bank_state = '0'",
			orderby:"bank_id asc",
			from:1,
			to:20
		});
		createSysCode({id:"agtCertType",codeType:"CERT_TYPE",value:"1"});
		$.addNumber("makeBatchId");
		$.autoComplete({
			id:"taskId",
			text:"task_id",
			value:"task_name",
			table:"card_apply_task",
			keyColumn:"task_id",
			optimize:true,
			minLength:"1"
		},"taskName");
		$.autoComplete({
			id:"taskName",
			text:"task_name",
			value:"task_id",
			table:"card_apply_task",
			keyColumn:"task_name",
			optimize:true,
			minLength:"1"
		},"taskId");
		$grid = createDataGrid({
			id:"dg",
			url:"taskManagement/taskManagementAction!getTaskReceiveRegistInfo.action",
			border:false,
			fit:true,
			scrollbarSize:0,
			singleSelect:false,
			showFooter:true,
			pageList:[50,100,200,300,500],
			frozenColumns:[[
	   				{field:"SETTLEID",title:"id",sortable:true,checkbox:true},
	   				{field:"TASK_ID",title:"任务编号",sortable:true,width : parseInt($(this).width() * 0.12)},
	   				{field:"TASK_NAME",title:"任务名称",sortable:true},
	   				{field:"TASK_STATE",title:"任务状态",sortable:true},
	   				{field:"REGIST_STATE",title:"登记状态",sortable:true,width : parseInt($(this).width() * 0.06), formatter:function(v){
	   					if(v == 0){
	   						return "<span style='color:orange'>未登记</span>";
	   					} else if(v == 1){
	   						return "<span style='color:green'>已登记</span>";
	   					}
	   					return v;
	   				}}
	   		]],
	   		columns:[[
	   				{field:"AGT_NAME",title:"领卡人",sortable:true},
	   				{field:"AGT_CERT_NO",title:"领卡人证件号码",sortable:true},
	   				{field:"OPER_BRCH_NAME",title:"办理网点",sortable:true},
	   				{field:"USER_NAME",title:"办理柜员",sortable:true},
	   				{field:"BIZ_TIME",title:"办理时间",sortable:true},
	   				{field:"MAKE_BATCH_ID",title:"批次号",sortable:true},
	   				{field:"TASK_WAY",title:"任务组织方式",sortable:true},
	   				{field:"CORP_NAME",title:"单位名称",sortable:true},
	   				{field:"TASK_DATE",title:"任务时间",sortable:true},
	   				{field:"IS_URGENT",title:"制卡方式",sortable:true},
	   				{field:"TASK_SUM",title:"任务初始数量",sortable:true},
	   				{field:"BANK_ID",title:"审核银行编号",sortable:true},
	   				{field:"BANK_NAME",title:"审核银行名称",sortable:true},
	   				{field:"YH_NUM",title:"审核成功数量",sortable:true},
	   				{field:"BRCH_NAME",title:"领卡网点",sortable:true}
	   		]],
			fitColumns:true,
			onBeforeLoad:function(p){
				if(!p.query){
					return false;
				}
				return true;
			},
			onSelect:function(i, r){
				if(r.CON_CERT_NO){
					$("#agtCertNo").val(r.CON_CERT_NO);
				}
				if(r.CONTACT){
					$("#agtName").val(r.CONTACT);
				}
				if(r.CON_PHONE){
					$("#agtTelNo").val(r.CON_PHONE);
				}
			}
		});
	});
	function toQuery(){
		var params = getformdata("searchConts");
		params.query = true;
		$grid.datagrid("load", params);
	}
	function regist(){
		var selections = $("#dg").datagrid("getSelections");
		if(!selections || selections.length != 1){
			$.messager.alert("系统消息","请选择一条任务！", "warning");
			return;
		} else if(selections[0].STATE != "40" && selections[0].STATE != "50"){
			$.messager.alert("系统消息","任务不是【已接收】或【发放中】状态，不能进行登记！", "warning");
			return;
		} else if(selections[0].REGIST_STATE == 1){
			$.messager.alert("系统消息","任务【已登记】，不能再进行登记！", "warning");
			return;
		}
		if(!$("#agtName").val() || !$("#agtCertNo").val()){
			$.messager.alert("系统消息","领卡人信息不能为空！", "warning");
			return;
		}
		var params = getformdata("form");
		params.taskIds = selections[0].TASK_ID;
		params["rec.agtName"] = $("#agtName").val();
		$.messager.progress({text:'数据处理中，请稍后....'});
		$.post("taskManagement/taskManagementAction!taskReceiveRegist.action", params, function(data){
			$.messager.progress('close');
			if(!data || data.status != 0){
				jAlert(data.errMsg);
				return;
			} else {
				jAlert("领卡登记成功", "info", function(){
					toQuery();
				});
			}
		}, "json");
	}
	function readIdCard2(){
		$.messager.progress({text:'正在获取证件信息，请稍后....'});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress('close');
		$("#agtCertType").combobox("setValue",'1');
		$("#agtCertNo").val(certinfo["cert_No"]);
		$("#agtName").val(certinfo["name"]);
	}
	
	function readSMK2(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#agtCertType").combobox("setValue","1");
		$("#agtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#agtName").val(dealNull(queryCertInfo["name"]));
	}
	
	function exportData(){
		var selection = $("#dg").datagrid("getSelections");
		var paramStr = "";
		if(selection && selection.length > 0){
			for(var i in selection){
				paramStr += selection[i].TASK_ID + ",";
			}
			if(paramStr){
				paramStr = paramStr.substring(0, paramStr.length - 1);
			}
		}
		//
		var paramString = "";
		var params = getformdata("searchConts");
		if(params){
			for(var i in params){
				paramString += "&" + i + "=" + params[i];
			}
		}
		if(paramStr){
			paramString += "&selectIds=" + paramStr;
		}
		if(paramString){
			paramString = paramString.substring(1);
		}
		$("#download").attr("src", "taskManagement/taskManagementAction!exportReceiveRegistData.action?" + paramString);

	}
</script>
<n:initpage title="【已接收】，【发放中】的任务做领卡登记操作">
	<n:center>
		<div id="tb">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">批次号：</td>
						<td class="tableright"><input id="makeBatchId" name="task.makeBatchId" type="text" class="textinput" maxlength="15"/></td>
						<td class="tableleft">任务号：</td>
						<td class="tableright"><input id="taskId" name="task.taskId" type="text" class="textinput" maxlength="20"/></td>
						<td class="tableleft">任务名称：</td>
						<td class="tableright"><input id="taskName" name="task.taskName" type="text" class="textinput"/>
						</td>
						<td class="tableleft">审核银行：</td>
						<td class="tableright"><input id="bankId" name="task.bankId" type="text" class="textinput"/>
						</td>
					</tr>
					<tr>
						<td class="tableleft">办理时间：</td>
						<td class="tableright" colspan="3">
							<input id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
							&nbsp;&nbsp;——&nbsp;&nbsp;
							<input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
						</td>
						<td class="tableleft" colspan="4" style="padding-right: 20px">
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:false"   onclick="toQuery()">查询</a>
							&nbsp;&nbsp;<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-save',plain:false" onclick="regist();">领卡登记</a>
							&nbsp;&nbsp;<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-export',plain:false" onclick="exportData();">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="任务信息"></table>
    </n:center>
    <div data-options="region:'south',split:false,border:true" style="height:100px; width:100%;text-align:center;overflow:hidden;border-bottom:none;border-left:none;">
	  	<form id="form" method="post" class="datagrid-toolbar" style="width:100%;height:100%;">
	  		<h3 class="subtitle">领卡人信息</h3>
			 <table width="100%" class="tablegrid">
				 <tr>
					<th class="tableleft">领卡人证件类型：</th>
					<td class="tableright"><input id="agtCertType" name="rec.agtCertType" type="text" class="easyui-combobox  easyui-validatebox"  value="1" style="width:174px;"/> </td>
					<th class="tableleft">领卡人证件号码：</th>
					<td class="tableright"><input id="agtCertNo" name="rec.agtCertNo" type="text" class="textinput easyui-validatebox" maxlength="18"/></td>
					<th class="tableleft">领卡人姓名：</th>
					<td class="tableright"><input id="agtName" name="rec.agtName" type="text" class="textinput easyui-validatebox"   maxlength="30" /></td>
				 	<th class="tableleft">领卡人联系电话：</th>
					<td class="tableright"><input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox"  maxlength="11" validtype="mobile"/></td>
				</tr>
				<tr>
					<td class="tableleft" colspan="8">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
					</td>
				</tr>
			 </table>
		</form>			
	</div>
	<iframe id="download" style="display: none"></iframe>
</n:initpage>