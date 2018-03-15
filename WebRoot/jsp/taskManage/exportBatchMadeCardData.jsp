<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<!-- 制卡任务导出,按照批次方式进行导出 -->
<script type="text/javascript">
	var $grid;
	$(function() {
		createSysCode({
			id:"taskState",
			codeType:"TASK_STATE",
			codeValue:"<%=com.erp.util.Constants.TASK_STATE_YHYSH%>",
			isShowDefaultOption:false
		});
		createRegionSelect(
			{id:"regionId"},
			{id:"townId"},
			{id:"commId"}
		);
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_SMZK %>",
			isShowDefaultOption:false
		});
		createCustomSelect({
			id:"vendorId",
			value:"vendor_id",
			text:"vendor_name",
			table:"base_vendor", 
			where:"state = '0'",
			orderby:"vendor_id asc"
		});
		$grid = createDataGrid({
			id:"dg",
			url:"taskManagement/taskManagementAction!cardTaskQuery.action",
			border:false,
			fit:true,
			singleSelect:false,
			fitColumns:true,
			scrollbarSize:0,
			columns:[[   
			    {field:"SETTLEID",title:"id",sortable:true,checkbox:true},
				{field:"TASK_ID",title:"任务编号",sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASKSTATE",title:"任务状态",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASKWAY",title:"任务组织方式",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASK_NAME",title:"任务名称",sortable:true,width : parseInt($(this).width() * 0.3)},
				{field:"TASK_DATE",title:"任务时间",sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:"CARD_TYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"IS_URGENT",title:"制卡方式",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASK_SUM",title:"任务数量",sortable:true,width : parseInt($(this).width() * 0.08)}
			]]
		});
		var pager = $grid.datagrid("getPager");
        pager.pagination({
            buttons:$("#zhuguanPwdDiv")
        }); 
		$.addNumber("makeBatchId");
		$.addNumber("taskId");
		$.addNumber("corpId");
	});
	function toQuery(){
		var params = getformdata("searchConts");
		params["queryType"] = "0";
		$grid.datagrid("load",params);
	}
	function viewTaskList(){
		var rows = $grid.datagrid("getChecked");
		if(rows && rows.length == 1){
			$.messager.progress({text:"正在加载，请稍后...."});
			$.modalDialog({
				title:"预览任务明细",
				iconCls:"icon-viewInfo",
				shadow:false,
				border:false,
				maximized:true,
				shadow:false,
				closable:false,
				maximizable:false,
				href:"jsp/taskManage/viewCardTask.jsp?taskId=" + rows[0].SETTLEID + "&taskState=" + rows[0].TASK_STATE +
						"&taskStateName=" + escape(encodeURIComponent(rows[0].TASKSTATE)) + "&taskWay=" + rows[0].TASK_WAY +
						"&tempTaskWay=<%=com.erp.util.Constants.TASK_WAY_WD%>" + "&tempTaskState=<%=com.erp.util.Constants.TASK_STATE_YSC%>" ,
				buttons:[
					{
						iconCls:"icon_cancel_01",
						text:"关闭",
						handler:function(){
							$grid.datagrid("reload");
							$.messager.progress("close");
							$.modalDialog.handler.dialog("destroy");
						    $.modalDialog.handler = undefined;
					    }
					}
				]
			});
		}else{
			$.messager.alert("提示信息","请选择一条记录进行预览","error");
		}
	}
	function exportVendor(){
		var vendorId = $("#vendorId").combobox("getValue");
		var rows = $grid.datagrid("getChecked");
		var taskIds = "";
		if(!rows || rows.length <= 0){
			$.messager.alert("系统消息","请勾选将要进行导出的任务记录信息！","error");
			return;
		}
		if(dealNull(vendorId) == ""){
			$.messager.alert("系统消息","请选择制卡卡商信息！","error",function(){
				$("#vendorId").combobox("showPanel");
			});
			return false;
		}
		for(var i = 0;i < rows.length;i++){
			if(rows[i].TASK_STATE != <%=com.erp.util.Constants.TASK_STATE_YHYSH%>){
				$.messager.alert("系统消息","任务编号为【" + rows[i].SETTLEID + "】的任务状态不为【银行已审核】！","error");
				return;
			}
			if(i == rows.length - 1){
				taskIds = taskIds + rows[i].SETTLEID;
			}else{
				taskIds = taskIds + rows[i].SETTLEID + "|";
			}
		}
		$.messager.confirm("系统消息","您确定要将勾选的任务导出给【" + $("#vendorId").combobox("getText") + "】进行制卡吗？",function(is){
			if(is){
				$.messager.progress({text:"数据处理中，请稍后...."});
				$.ajax({
					dataType:"json",
					global:true,
					url:"taskManagement/taskManagementAction!exportMadeCardData.action",
				    data:{
				    	"task.vendorId":$("#vendorId").combobox("getValue"),
				    	taskIds:taskIds
				    },
					success:function(rsp){
						$.messager.progress("close");
						if(dealNull(rsp.status) == "0"){
							$.messager.alert("系统消息",rsp.errMsg,"info",function(){
								$("#bankId").combobox("setValue","");
								toQuery();
							});
						}else{
							$.messager.alert("系统消息",rsp.errMsg,"error");
						}
					}
				});
			}
		});
	}
	function autoCom(){
		if($("#corpId").val() == ""){
			$("#corpName").val("");
		}
		$("#corpId").autocomplete({
			position: {my:"left top",at:"left bottom",of:"#corpId"},
		    source: function(request,response){
			    $.post("dataAcount/dataAcountAction!toSearchInput.action",{"corpName":$("#corpId").val()},function(data){
			    	response($.map(data,function(item){return {label:item.text,value:item.value};}));
			    });
		    },
		    select: function(event,ui){
		      	$("#corpId").val(ui.item.label);
		        $("#corpName").val(ui.item.value);
		        return false;
		    },
	      	focus:function(event,ui){
		        return false;
	      	}
	    }); 
	}
	function autoComByName(){
		if($("#corpName").val() == ""){
			$("#corpId").val("");
		}
		$("#corpName").autocomplete({
		    source:function(request,response){
		        $.post("dataAcount/dataAcountAction!toSearchInput.action",{"corpName":$("#corpName").val(),"queryType":"0"},function(data){
		            response($.map(data,function(item){return {label:item.value,value:item.text};}));
		        });
		    },
		    select: function(event,ui){
		      	$("#corpId").val(ui.item.value);
		        $("#corpName").val(ui.item.label);
		        return false;
		    },
		    focus: function(event,ui){
		        return false;
		    }
	    }); 
	}
</script>
<n:initpage title="制卡数据进行导出操作！<span style='color:red'>注意：</span>只有任务状态为【银行已审核】的任务才能进行制卡数据导出操作，导出时必须按照整批次导出，不能单独任务导出！">
	<n:center>
		<div id="tb">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">批次号：</td>
						<td class="tableright"><input id="makeBatchId" name="task.makeBatchId" type="text" class="textinput" maxlength="15"/></td>
						<td class="tableleft">任务号：</td>
						<td class="tableright"><input id="taskId" name="task.taskId" type="text" class="textinput" maxlength="20"/></td>
						<td class="tableleft">任务状态：</td>
						<td class="tableright"><input id="taskState" name="task.taskState" type="text" class="textinput"/></td>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" name="task.cardType" type="text"  class="textinput"/></td>
					</tr>
					<tr>
	                    <td class="tableleft">单位编号：</td>
						<td class="tableright"><input id="corpId" name="task.corpId" type="text" class="textinput" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
						<td class="tableleft">单位名称：</td>
						<td class="tableright" ><input id="corpName" name="corpName" type="text" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
						<td class="tableleft">任务开始日期：</td>
						<td class="tableright"><input id="taskStartDate" name="taskStartDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">任务结束日期：</td>
						<td class="tableright"><input id="taskEndDate" name="taskEndDate" type="text"  class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
					    <td class="tableleft">所在城区：</td>
						<td class="tableright"><input id="regionId" name="task.regionId"  type="text" class="textinput"/></td>
						<td class="tableleft">所在乡镇：</td>
						<td class="tableright"><input id="townId" name="task.townId" type="text" class="textinput"/></td>
						<td class="tableleft">社区(村)：</td>
						<td class="tableright"><input id="commId" name="task.commId" type="text" class="textinput"/></td>
						<td style="text-align:center;" colspan="2">
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:false"   onclick="toQuery()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-viewInfo',plain:false" onclick="viewTaskList();">任务预览</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="任务信息"></table>
  		<div id="zhuguanPwdDiv">
            <table>
                <tr> 
				  	<shiro:hasPermission name="cardOnlyTaskExpToBank">
						<td align="right">&nbsp;&nbsp;卡厂：</td>
		 				<td>
		 					<input id="vendorId" name="vendorId" type="text" class="easyui-combobox"  style="width:124px;"/>
		 					<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-export"  plain="false" onclick="exportVendor();">导出卡厂</a>
		 				</td>
  				 	</shiro:hasPermission>
                 </tr>
            </table>
        </div> 
    </n:center>
</n:initpage>