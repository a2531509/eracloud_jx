<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var  $grid;
	$(function(){
		$.autoComplete({
			id:"corpId",
			text:"customer_id",
			value:"corp_name",
			table:"base_corp",
			keyColumn:"customer_id",
			minLength:"1"
		},"corpName");
		$.autoComplete({
			id:"corpName",
			text:"corp_name",
			value:"customer_id",
			table:"base_corp",
			keyColumn:"corp_name",
			minLength:"1"
		},"corpId");
 		$grid = createDataGrid({
			id:"dg1",
			url:"cardapply/cardApplyAction!jrsbkHfPersonInfo.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			singleSelect:true,
			pageList:[50, 100, 200, 500, 1000],
			singleSelect:false,
			pageSize:20,
			fitColumns:true,
			toolbar:"#tb1",
			columns:[[
					{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:"90px"},
					{field:"NAME",title:"姓名",sortable:true,width:"90px"},
					{field:"CERTTYPE",title:"证件类型",sortable:true},
					{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.16)},
					{field:"CORP_NAME",title:"单位",sortable:true,width:parseInt($(this).width()*0.2)},
					{field:"REGION_NAME",title:"所属区域",sortable:true},
					{field:"TOWN_NAME",title:"乡镇（街道）",sortable:true},
					{field:"COMM_NAME",title:"社区（村）",sortable:true},
					{field:"MOBILE_NO",title:"联系电话",sortable:true}
			]],
			onBeforeLoad:function(params){
				if(!params["query"]){
					return false;
				}
			}
		});
 		$grid2 = createDataGrid({
			id:"dg2",
			url:"cardapply/cardApplyAction!jrsbkHfPersonInfo2.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			singleSelect:true,
			pageList:[50, 100, 200, 500, 1000],
			singleSelect:false,
			pageSize:20,
			fitColumns:true,
			toolbar:"#tb2",
			columns:[[
					{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:"90px"},
					{field:"NAME",title:"姓名",sortable:true,width:"90px"},
					{field:"CERTTYPE",title:"证件类型",sortable:true},
					{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.16)},
					{field:"CORP_NAME",title:"单位",sortable:true,width:parseInt($(this).width()*0.2)},
					{field:"REGION_NAME",title:"所属区域",sortable:true},
					{field:"TOWN_NAME",title:"乡镇（街道）",sortable:true},
					{field:"COMM_NAME",title:"社区（村）",sortable:true},
					{field:"MOBILE_NO",title:"联系电话",sortable:true},
					{field:"NOTE",title:"备注",sortable:false, formatter:function(value){
						if(value == '0') {
					 		return "<span style='color:orange'>人员状态不正常</span>";
					 	} else if(value == '1') {
					    	return "<span style='color:orange'>证件类型不是身份证</span>";
					 	} else if(value == '2') {
					    	return "<span style='color:orange'>照片不存在</span>";
					 	} else if(value == '3') {
					 		return "<span style='color:orange'>全功能卡已绑定银行卡</span>";
					 	}
					    return "<span style='color:red'>" + value + "</span>";
					}}
			]],
			onBeforeLoad:function(params){
				if(!params["query"]){
					return false;
				}
			}
		});
	});
	function query(){
		var corpId = $("#corpId").val();
		if(!corpId){
			jAlert("单位编号不能为空！","warning");
			return;
		}
		$grid.datagrid("load", {companyNo:corpId, query:true});
		$grid2.datagrid("load", {companyNo:corpId, query:true});
	}
	function exportDetail() {
		var corpId = $("#corpId").val();
		if(!corpId){
			jAlert("单位编号不能为空！","warning");
			return;
		}
		$.messager.progress({text:"正在进行导出,请稍候..."});
		$.post("cardapply/cardApplyAction!printExportJrsbkHfPersonInfo.action", {companyNo:corpId}, function(data){
			if(data.status == '1'){
				$.messager.progress("close");
				jAlert(data.errMsg,"error");
				return;
			}
			showReport("嘉兴金融市民卡批量换发领卡通知单",data.dealNo, function(){
				$('#download_iframe').attr('src',"cardapply/cardApplyAction!exportJrsbkHfPersonInfo.action?companyNo=" + corpId);
			});
		}, "json");
		startCycle();
	}
	
	function startCycle(){
		isExt = setInterval("startDetect()",800);
	}
	function startDetect(){
		commonDwr.isDownloadComplete("exportJrsbkHfPersonInfo",function(data){
			if(data["returnValue"] == '0'){
				clearInterval(isExt);
				jAlert("导出成功！","info",function(){
					$.messager.progress("close");
				});
			}
		});
	}
</script>
<n:initpage title="单位符合批量换发人员信息进行查看！">
	<n:center>
	  	<div id="tb1">
	  		<form id="applyMsgForm" >
				<table class="tablegrid" style="width: auto;">
					<tr>
						<td class="tableleft">单位编号：</td>
						<td  class="tableright"><input name="apply.corpId"  class="textinput" id="corpId" type="text" maxlength="20"/></td>
						<td  class="tableleft">单位名称：</td>
						<td  class="tableright">
							<input name="corpName"  class="textinput" id="corpName" type="text" maxlength="30"/>
					    	&nbsp;&nbsp;<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0)" class="easyui-linkbutton" onclick="query()">查询</a>
					    	<a data-options="plain:false,iconCls:'icon-export'" href="javascript:void(0)" class="easyui-linkbutton" onclick="exportDetail()">导出</a>
					    </td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg1" title="单位符合批量换发人员信息"></table>
	</n:center>
	<div data-options="region:'south',split:false,border:true" style="height:50%; width:100%;text-align:center;overflow:hidden;border-bottom:none;border-left:none;">
		<div id="tb2"></div>
		<table id="dg2" title="单位不符合批量换发人员信息"></table>
	</div>
	<iframe id="download_iframe" style="display: none;"></iframe>
</n:initpage>