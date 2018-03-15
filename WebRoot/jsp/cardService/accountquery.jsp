<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@include file="../../layout/initpage.jsp" %>
<!-- 账户信息查询 -->
<script type="text/javascript">
	var $grid;
	var cardinfo
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
		});
		$grid = createDataGrid({
			id:"dg",
			url:"cardService/cardServiceAction!accountQuery.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			scrollbarSize:0,
			singleSelect:true,
			frozenColumns:[[
				{field:"CUSTOMER_ID",title:"客户编号 ",sortable:true,width:parseInt($(this).width() * 0.07)},
				{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"CERTTYPE",title:"证件类型",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.13)}
			]],
			columns:[[
				{field:"CARDTYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"BUSTYPE",title:"公交类型",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"CARDSTATE",title:"卡状态",sortable:true,width:parseInt($(this).width() * 0.06)},
	        	{field:"ACCKIND",title:"账户类型",sortable:true,width:parseInt($(this).width() * 0.06)},
	        	{field:"BAL",title:"余额",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
	        		if(row.ACC_KIND == "01"){
	        			return "<div title=\"注：钱包账户为脱机消费，消费数据未实时上传结算时，账户余额可能大于卡面余额\" style=\"font-weight:600;TEXT-DECORATION:underline;font-style:italic;color:red;width:100%;height:100%;\" class=\"easyui-tooltip\">" + value + "</div>";
	        		}else{
	        			return value;
	        		}
	        	}},
	        	{field:"FRZ_AMT",title:"冻结金额",sortable:true},
	        	{field:"FRZ_DATE",title:"冻结日期",sortable:true},
	        	{field:"AVAILABLEAMT",title:"可用余额",sortable:true},
	        	{field:"BAL_RSLT",title:"余额处理结果",sortable:true},
	        	{field:"LAST_DEAL_DATE",title:"最后交易日期",sortable:true,width:parseInt($(this).width() * 0.12)},
	        	{field:"OPEN_BRCH_ID",title:"开户网点",sortable:true,width:parseInt($(this).width() * 0.12)},
	        	{field:"OPEN_USER_ID",title:"开户柜员",sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:"OPEN_DATE",title:"开户日期",sortable:true,width:parseInt($(this).width() * 0.12)},
	        	{field:"LSS_DATE",title:"挂失日期",sortable:true,width:parseInt($(this).width() * 0.12)},
	        	{field:"CLS_DATE",title:"注销日期",sortable:true,width:parseInt($(this).width() * 0.12)},
	        	{field:"CLS_USER_ID",title:"注销柜员",sortable:true,width:parseInt($(this).width() * 0.08)}
	        ]]
		});
	});
	function query(){
		if($("#certNo").val().replace(/\s/g,'') == '' && $("#cardNo").val().replace(/\s/g,'') == ''){
			jAlert("请输入查询证件号码或是卡号！");
			return;
		}
		$grid.datagrid("load",{
			queryType:"0",
			certNo:$("#certNo").val(), 
			cardNo:$("#cardNo").val()
		});
	}
	function readCard(){
		$.messager.progress({text:"正在获取卡片信息，请稍后...."});
		cardinfo = getcardinfo();
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardinfo["errMsg"] ,"error");
			return;
		}else{
			$.messager.progress("close");
			$("#cardNo").val(cardinfo["card_No"].trim());
			$("#cardAmt").val((parseFloat(isNaN(cardinfo["wallet_Amt"]) ? 0:cardinfo["wallet_Amt"])/100).toFixed(2));
			query();
		}
	}
	function readIdCard(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var o = getcertinfo();
		if(dealNull(o["name"]).length == 0){
			$.messager.progress("close");
			return;
		}
		$.messager.progress("close");
		$("#certNo").val(o["cert_No"]);
		query();
	}
</script>
<n:initpage title="卡片账户信息进行查询操作！">
	<n:center>
	  	<div id="tb" style="padding:2px 0">
			<table class="tablegrid">
				<tr>
					<tr>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input name="certNo"  class="textinput" id="certNo" type="text" /></td>
						<td class="tableleft">卡号：</td>
						<td class="tableright"><input name="cardNo"  class="textinput" id="cardNo" type="text" /></td>
						<td class="tableleft">卡余额：</td>
						<td class="tableright"><input id="cardAmt" type="text" class="textinput" name="cardAmt" style="width:174px;" readonly="readonly"/></td>
						<td class="tableright">
							<shiro:hasPermission name="accountQuery">
								<a  data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0)" class="easyui-linkbutton"  id="readcard" name="readcard"  onclick="readCard()">读卡</a>
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							</shiro:hasPermission>
						</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="账户信息"></table>
	</n:center>
</n:initpage>