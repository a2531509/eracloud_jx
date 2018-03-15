<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript"> 
	$(function(){
		$("#dia").dialog({
    		title:"卡交易对账明细",
    		fit:true,
    		closed:true,
    		border:false,
    		modal:true,
    		onBeforeOpen:function(){
    			var selections = $("#dg").datagrid("getSelections");
    			if(selections.length != 1){
    				$.messager.alert("系统消息","请选择一条记录","warning");
    				return false;
    			}
	    		var regionId = selections[0].REGION_ID;
	    		var date = selections[0].DZ_DATE;
    			$("#dg2").datagrid("load", {regionId:regionId, startDate:date});
    		}
    	});
		
		createRegionSelect({id:"regionId"});
		
		$("#dzState").combobox({
			valueField:"value",
			textField:"text",
			panelHeight:"auto",
			data:[
				{value:"", text:"请选择"},
				{value:"0", text:"对账通过"},
				{value:"-1", text:"对账未通过"}
			],
			editable:false
		});
		
		$("#dg").datagrid({
			url:"pgData/pgDataAction!getCardDzData.action",
			fitColumns:true,
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			toolbar:"#tb",
			pageList:[50, 100, 200, 500, 1000],
			singleSelect:true,
			columns:[[
				{field:"DEAL_NO", checkbox:true},
				{field:"DZ_DATE",title:"对账日期",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"REGION_NAME",title:"区域",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"DZ_STATE",title:"对账状态",sortable:true, formatter:function(v, r, i){
					if(v == 0){
						return "对账通过";
					} else if(v == -1){
						return "对账未通过";
					}
					return v;
				}},
				{field:"TOT_CARD_NUM",title:"发送卡数量",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"NORMAL_CARD_NUM",title:"正常卡数量",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"LOSS_CARD_NUM",title:"挂失卡数量",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"PRELOSS_CARD_NUM",title:"临时挂失卡数量",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"ST_TOT_CARD_NUM",title:"省厅收到卡数量",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"ST_NORMAL_CARD_NUM",title:"省厅正常卡数量",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"ST_LOSS_CARD_NUM",title:"省厅挂失卡数量",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"ST_PRELOSS_CARD_NUM",title:"省厅临时挂失卡数量",sortable:true,width:parseInt($(this).width()*0.1)}
			]],
			onBeforeLoad:function(params){
				if(!params.query){
					return false;
				}
			},
            onLoadSuccess:function(data){
            	if(data.status != 0){
            		jAlert(data.errMsg,"warning");
            	}
            }
		});
		
		$("#dg2").datagrid({
			url:"pgData/pgDataAction!getCardDzDataDetail.action",
			fitColumns:true,
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			toolbar:"#tb2",
			pageList:[50, 100, 200, 500, 1000],
			singleSelect:true,
			columns:[[
				{field:"DEAL_NO", checkbox:true},
				{field:"ST_PERSON_ID",title:"省厅人员编号",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"SUB_CARD_NO",title:"社保卡号",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"SUB_CARD_ID",title:"社保卡编码",sortable:true,width:parseInt($(this).width()*0.15)},
				{field:"CARD_STATE",title:"卡交易类型",sortable:true,width:parseInt($(this).width()*0.08), formatter:function(v){
					if(v == 1){
						return "卡新增";
					} else if(v == 2){
						return "临时挂失";
					} else if(v == 3){
						return "挂失";
					}
					return v;
				}},
				{field:"STATE",title:"对账状态",sortable:true,width:parseInt($(this).width()*0.08), formatter:function(v){
					if(v == 0){
						return "<span style='color:green'>共同存在</span>";
					} else if(v == 1){
						return "<span style='color:orange'>本地多出</span>";
					} else if(v == 2){
						return "<span style='color:orange'>省厅多出</span>";
					}
					return v;
				}}
			]],
            onLoadSuccess:function(data){
            	if(data.status != 0){
            		jAlert(data.errMsg,"warning");
            	}
            }
		});
		
	})
	
	function query() {
		var params = getformdata("searchConts");
		params.query = true;
		$("#dg").datagrid("load", params);
	}
		
	function readCard(){
		$.messager.progress({text : "正在验证卡信息,请稍后..."});
		cardinfo = getcardinfo();
		$.messager.progress("close");
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！","error");
			return;
		}
		$("#cardNo").val(cardinfo["card_No"]);
		query();
	}
	
	function reSendCardData(){
		var selections = $("#dg2").datagrid("getSelections");
		if(selections.length != 1){
			$.messager.alert("系统消息","请选择一条记录","warning");
			return;
		} else if(selections[0].STATE != 1){
			$.messager.alert("系统消息","该卡交易数据不是本地多出， 不能补发","warning");
			return;
		}
		var cardState = selections[0].CARD_STATE;
		$.messager.progress({text:"数据处理中..."});
		if(cardState == 1) {
			$.post("pgData/pgDataAction!sendPerson.action", {certNo:selections[0].CERT_NO}, function(data){
				$.messager.progress("close");
				if (data.status == 1) {
					$.messager.alert("消息提示", data.errMsg, "error");
				} else {
					$.messager.alert("消息提示", "发送成功", "info");
				}
			}, "json");
		} else if (cardState == 2 || cardState == 3) {
			$.post("pgData/pgDataAction!updateCardState.action", {subCardId:selections[0].SUB_CARD_ID, cardStateAfterChange:cardState}, function(data){
				$.messager.progress("close");
				if (data.status == 1) {
					$.messager.alert("消息提示", data.errMsg, "error");
				} else {
					$.messager.alert("消息提示", "变更卡状态成功", "info");
				}
			}, "json");

		} else {
			$.messager.alert("消息提示", "未知卡交易类型", "error");
		}
	}
	
	function viewInfo(){
		$("#dia").dialog("open");
	}
</script>
<n:initpage title="发送省厅卡信息进行对账查询！">
	<n:center>
		<div id="tb" class="datagrid-toolbar">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">区域：</td>
						<td class="tableright"><input  id="regionId" type="text" class="textinput" name="regionId" /></td>
						<td class="tableleft">对账起始日期：</td>
						<td class="tableright"><input name="startDate"  class="Wdate textinput" id="beginTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyyMMdd',qsEnabled:false,maxDate:'%y%M%d'})"/></td>
						<td class="tableleft">对账结束日期：</td>
						<td class="tableright"><input name="endDate"  class="Wdate textinput" id="endTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyyMMdd',qsEnabled:false,maxDate:'%y%M%d'})"/></td>
						<td class="tableleft">对账状态：</td>
						<td class="tableright"><input  id="dzState" type="text" class="textinput" name="state" /></td>
					</tr>
					<tr>
						<td class="tableleft" colspan="8" style="padding-right: 20px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-viewInfo" plain="false" onclick="viewInfo()">预览</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="省厅卡交易对账数据"></table>
  	</n:center>
  	<div id="dia" >
  		<div id="tb2" class="tablegrid">
  			<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-add'" onclick="reSendCardData()">数据补发</a>
  		</div>
       	<table id="dg2" style="width:100%"></table>
  	</div>
</n:initpage>